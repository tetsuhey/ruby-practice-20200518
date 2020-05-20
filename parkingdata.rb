YEALY_BTN_CLASS_NAME = "button.yearly-btn" #年報ボタン
MONTHLY_BTN_CLASS_NAME = "button.monthly-btn" #月報ボタン
    
URIAGE_BTN_CLASS_NAME = "button#saleAggreBtn" #売上集計ボタン
SYASHITUBETSU_BTN_CLASS_NAME = "button#roomSaleBtn" #車室別ボタン
JIKANTAI_BTN_CLASS_NAME = "button#timeSaleBtn" #時間帯別ボタン
YOUBI_BTN_CLASS_NAME = "button#dayOfTheWeekSalesBtn" #曜日別ボタン
CYUSYAJIKAN_BTN_CLASS_NAME = "button#timeAmountBtn" #駐車時間帯別ボタン

SYUKEIBI_Y_START_TXT_CLASS_NAME = "input#chooseOneMonI" #集計開始日選択(年報)
SYUKEIBI_M_START_TXT_CLASS_NAME = "input#chooseOneStartDateIM" #集計開始日選択(月報)
SEIKYU_BTN_CLASS_NAME = "input#requestInput" #請求ボタン

SHOW_GRAPH_BTN_CLASS_NAME = "button#graphButton" #グラフ表示ボタン

class ParkingElems

    def initialize(browser)
        @browser = browser
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
            p "PDFを保存!"
            return true
        else
            p "ERROR!"
            return false
        end
    end

    #**
    #年報の取得
    def getNenpou(attr)
        begin
            @browser.find(YEALY_BTN_CLASS_NAME).click #年報ボタンクリック
            @browser.find(URIAGE_BTN_CLASS_NAME).click #売上集計ボタンをクリック
            @browser.find(SYUKEIBI_Y_START_TXT_CLASS_NAME).send_keys(attr[:date])#請求開始の日付を入力
            unless @browser.find(SEIKYU_BTN_CLASS_NAME).selected?
                @browser.find(SEIKYU_BTN_CLASS_NAME).click #請求にチェック
            end
            
            @browser.find(SHOW_GRAPH_BTN_CLASS_NAME).click #グラフ表示ボタンクリック

            unless pdf_download
                p "PDFの保存に失敗しました"
                return false
            end
        rescue => exception
            p exception.class 
            return false
        end
    end



    #** 
    #月報の取得
    def getGeppou(attr)
        begin
            @browser.find(MONTHLY_BTN_CLASS_NAME).click #月報ボタンクリック

            case attr[:mode]
            when "売上"
                @browser.find(URIAGE_BTN_CLASS_NAME).click #売上集計ボタンをクリック
            when "車室"
                @browser.find(SYASHITUBETSU_BTN_CLASS_NAME).click #車室別ボタンをクリック
            when "時間帯"
                @browser.find(JIKANTAI_BTN_CLASS_NAME).click #時間帯ボタンをクリック
            when "曜日"
                @browser.find(YOUBI_BTN_CLASS_NAME).click #曜日別ボタンをクリック
            when "駐車時間"
                @browser.find(CYUSYAJIKAN_BTN_CLASS_NAME).click #駐車時間ボタンをクリック
            when "サービス情報"
            end

            
            @browser.find(SYUKEIBI_M_START_TXT_CLASS_NAME).send_keys(attr[:date])#請求開始の日付を入力
            unless @browser.find(SEIKYU_BTN_CLASS_NAME).selected?
                @browser.find(SEIKYU_BTN_CLASS_NAME).click #請求にチェック
            end

            @browser.find(SHOW_GRAPH_BTN_CLASS_NAME).click #グラフ表示ボタンクリック

            unless pdf_download
                p "PDFの保存に失敗しました"
                return false
            end

        rescue => exception
            p exception.class 
            return false
        end
    end

end

