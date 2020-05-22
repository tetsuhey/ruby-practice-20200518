require './report_file_creator'

YEALY_BTN_CLASS_NAME = "button.yearly-btn" #年報ボタン
MONTHLY_BTN_CLASS_NAME = "button.monthly-btn" #月報ボタン

SYUKEI_BTN_CLASS_NAME = "a#aggregateBtn" #集計ボタン
    
URIAGE_BTN_CLASS_NAME = "button#saleAggreBtn" #売上集計ボタン
SYASHITUBETSU_BTN_CLASS_NAME = "button#roomSaleBtn" #車室別ボタン
JIKANTAI_BTN_CLASS_NAME = "button#timeSaleBtn" #時間帯別ボタン
YOUBI_BTN_CLASS_NAME = "button#dayOfTheWeekSalesBtn" #曜日別ボタン
CYUSYAJIKAN_BTN_CLASS_NAME = "button#timeAmountBtn" #駐車時間帯別ボタン
SERVICEINFO_BTN_CLASS_NAME = "button#serviceInfoBtn" #サービス券ボタン

SYUKEIBI_Y_START_TXT_CLASS_NAME = "input#chooseOneMonI" #集計開始日選択(年報)
SYUKEIBI_M_START_TXT_CLASS_NAME = "input#chooseOneStartDateIM" #集計開始日選択(月報)
SEIKYU_BTN_CLASS_NAME = "input#requestInput" #請求ボタン

SHOW_GRAPH_BTN_CLASS_NAME = "button#graphButton" #グラフ表示ボタン

class ParkingElems

    def initialize(browser,  parking_name = "")
        @browser = browser
        @p_name = parking_name
    end

    def find_savePDF_btn
        #保存ボタンを探す
        begin
            btns = @browser.finds("button.btn")
            btns.each do |btn|
                attr = btn.text.encode('UTF-8')
                if(attr == "保存")
                    return btn #download フォルダにPDF格納
                    break
                end
            end
        rescue => exception
            p "save btn undefined"
            p exception.class
        end
    end

    def pdf_download
        if(@browser.loading_wait("div.loading-outter"))
            saveBtn = find_savePDF_btn
            saveBtn.click #保存ボタンクリック
            return true
        else
            return false
        end
    end

    #**
    #年報の取得
    def getNenpou(attr)
        @browser.find(SYUKEI_BTN_CLASS_NAME).click #集計ボタンクリック
        @browser.find(YEALY_BTN_CLASS_NAME).click #年報ボタンクリック
        @browser.find(URIAGE_BTN_CLASS_NAME).click #売上集計ボタンをクリック
        
        #請求開始の日付を入力
        @browser.find(SYUKEIBI_Y_START_TXT_CLASS_NAME).send_keys("")
        @browser.find(SYUKEIBI_Y_START_TXT_CLASS_NAME).send_keys(attr[:date])
        @browser.find(URIAGE_BTN_CLASS_NAME).click #売上集計ボタンをクリック
        #請求にチェック
        if(@browser.isExist(SEIKYU_BTN_CLASS_NAME))
            unless @browser.find(SEIKYU_BTN_CLASS_NAME).selected?
                @browser.find(SEIKYU_BTN_CLASS_NAME).click
            end
        end

        @browser.find(SHOW_GRAPH_BTN_CLASS_NAME).click #グラフ表示ボタンクリック
        
        unless pdf_download
            p "PDFの保存に失敗しました"
            return false
        end
        
        sleep 3 #ダウンロード完了まで待機

        #ダウンロードしたPDFを指定のディレクトリに移動する。
        #ディレクトリ名は駐車場名
        dl_dir = DL_Files.new
        dl_dir.mv_file_to_dir(@p_name, attr[:mode])

    end



    #** 
    #月報の取得
    def getGeppou(attr)
        begin
            @browser.find(SYUKEI_BTN_CLASS_NAME).click #集計ボタンクリック
            @browser.find(MONTHLY_BTN_CLASS_NAME).click #月報ボタンクリック

            #請求開始の日付を入力
            @browser.find(SYUKEIBI_M_START_TXT_CLASS_NAME).send_keys("")
            @browser.find(SYUKEIBI_M_START_TXT_CLASS_NAME).send_keys(attr[:date])

            case attr[:mode]
                when "月報"
                    @browser.find(URIAGE_BTN_CLASS_NAME).click #売上集計ボタンをクリック
                when "車室別売上"
                    @browser.find(SYASHITUBETSU_BTN_CLASS_NAME).click #車室別ボタンをクリック
                when "月報（時間帯）"
                    @browser.find(JIKANTAI_BTN_CLASS_NAME).click #時間帯ボタンをクリック
                when "月報(曜日別売上)"
                    @browser.find(YOUBI_BTN_CLASS_NAME).click #曜日別ボタンをクリック
                when "月報駐車台数"
                    @browser.find(CYUSYAJIKAN_BTN_CLASS_NAME).click #駐車時間ボタンをクリック
                when "サービス情報"
                    @browser.find(SERVICEINFO_BTN_CLASS_NAME).click #サービス券ボタンをクリック
            end

            #請求にチェック
            if(@browser.isExist(SEIKYU_BTN_CLASS_NAME))
                unless @browser.find(SEIKYU_BTN_CLASS_NAME).selected?
                    @browser.find(SEIKYU_BTN_CLASS_NAME).click
                end
            end
            
            #グラフ表示ボタンクリック
            @browser.find(SHOW_GRAPH_BTN_CLASS_NAME).click

            #Loading 待機
            @browser.loading_wait("div.loading-outter")

            #モーダルが表示されている場合は、閉じるボタンをおす
            if @browser.isDisplayed("div.modal")
                @browser.find("button.close").click
            end

            #逃避情報を抜き出して、別ファイルに保管しておく
            if(attr[:mode] == "車室別売上")
                pef = Parking_Error_File.new(@browser, @p_name)
                pef.errorChk
            end

            unless pdf_download
                p "PDFの保存に失敗しました"
                return false
            end

            sleep 3 #ダウンロード完了まで待機

            #ダウンロードしたPDFを指定のディレクトリに移動する。
            #ディレクトリ名は駐車場名
            dl_dir = DL_Files.new
            dl_dir.mv_file_to_dir(@p_name, attr[:mode])

        rescue => exception
            p exception 
            return false
        end
    end

end

