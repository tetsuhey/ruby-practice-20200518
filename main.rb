require './selenium_controller'
require './file_controller'
require './parkingdata'

# ローディングのdiv読み込み完了まで待機する
def is_fin_loading(b, iscallback = false)
    if(!b.isExist("div.loading-outter"))
        return true
    end
    if(b.loading_wait("div.loading-outter"))
        return true
    else
        unless iscallback
            p "Loading Error. 終了します。"
            b.close
        end
        return false
    end
end

# Tableの中身が読み込み完了するまで待機する
def is_fin_tbl_loading(b, iscallback = false)
    if(b.isExist("table#parkChooseTable tbody tr td.sorting_1 a"))
        return true
    end
    if(b.loading_wait("table#parkChooseTable tbody tr td.sorting_1 a"))
        return true
    else
        unless iscallback
            p "Loading Error. 終了します。"
            b.close   
        end
        return false
    end
end

# 次行の駐車場データ読み込むためのルーティーン
def ready_for_next_row(browser)
    #ブラウザをリフレッシュ
    browser.reflesh
    #ロードを待機
    unless is_fin_loading(browser, true)
        is_fin_loading(browser, false)
    end
      
    # 一度トップ画面に戻ると、フロント側でセッションを再設定する仕様のため
    # もう一度要素を再取得する
        
    #駐車場一覧ボタンをクリック
    browser.find("div#ParkChoose").click

    #ロードを待機
    unless is_fin_loading(browser)
        return nil
    end
    unless is_fin_tbl_loading(browser)
        return nil
    end
    
    # 駐車場一覧テーブルを再取得
    tbl_rows = browser.finds("table#parkChooseTable tbody tr")

    return tbl_rows
end

def get_pdf_data(browser, sf, p_name, isFlap)

    #駐車場のページからPDFを取得する
    pe = ParkingElems.new(browser, p_name)
    attr = {}
    
    p "年報売上収集開始"
    attr = {date:sf.getdata("target-m"), mode:"年報"}
    pe.getNenpou(attr)
    
    p "月報売上収集開始"
    attr = {date:sf.getdata("target-d"), mode:"月報"}
    pe.getGeppou(attr)
    
    p "車室別収集開始"
    attr = {date:sf.getdata("target-d"), mode:"車室別売上"}
    if isFlap
        pe.getGeppou(attr)
    end
    
    p "時間帯別収集開始"
    attr = {date:sf.getdata("target-d"), mode:"月報（時間帯）"}
    pe.getGeppou(attr)    
    
    p "曜日別収集開始"
    attr = {date:sf.getdata("target-d"), mode:"月報(曜日別売上)"}
    pe.getGeppou(attr)
    
    p "駐車時間別収集開始"
    attr = {date:sf.getdata("target-d"), mode:"月報駐車台数"}
    pe.getGeppou(attr)

    p "サービス券情報収集開始"
    attr = {date:sf.getdata("target-d"), mode:"サービス情報"}
    unless isFlap
        pe.getGeppou(attr)
    end
end

# 駐車場テーブルの各行を回し、それぞれのページアクセスする。
def get_parking_data(browser, sf, tr_s)

    retry_arr = []
    tbl_rows = tr_s
    
    for index in 0..(tbl_rows.length - 1)
        
        park_row = tbl_rows[index]

        if park_row == nil
            p "WARNING : 指定された行の読み込みに失敗 ----"
            p index.to_s + "行目の駐車場データ"
            p tbl_rows

            tbl_rows = ready_for_next_row(browser)
            next
        end
        
        #出力対象外はスキップ
        if(!browser.find_target_row(park_row, "WS"))
            next
        end

        #フラップ式の駐車場とゲート式を区別
        isFlap = browser.find_target_row(park_row, "フラップ")

        #各駐車場のページに遷移
        park_link = browser.get_child_obj("td.sorting_1 a", park_row) #リンク要素
        p_name = park_link.text.encode('UTF-8') #駐車場名
        park_link.click
        p "↓↓↓↓↓" + p_name + "のデータ収集開始↓↓↓↓↓"

        # loadingを待つ
        if !is_fin_loading(browser, true)
            #timeoutになった行はリトライする配列へ
            retry_arr << {name: p_name, idx: index, obj: park_row}
            p retry_arr
            tbl_rows = ready_for_next_row(browser)
            next
        end

        # 接続できないモーダルがある場合はリトライする
        if browser.isDisplayed("div.modal")
            p "精算機接続エラー！！"
            #接続できなかった行はリトライする配列へ
            retry_arr << {name: p_name, idx: index, obj: park_row}
            p retry_arr
            browser.find("button.close").click
            tbl_rows = ready_for_next_row(browser)
            next
        end

        #駐車場ページからPDFを取得する
        p "Load完了。PDFの収集を開始"
        get_pdf_data(browser, sf, p_name, isFlap)
        p "↑↑↑↑↑" + p_name + "のデータ収集終了↑↑↑↑↑"
        
        #次行読み込みの用意
        if index != (tbl_rows.length - 1)
            tbl_rows = ready_for_next_row(browser)
        end
    end

    return retry_arr
end




#設定ファイルを読む
sf = SettingFile.new

#ブラウザを起動し、対象のURLを表示
browser = Browser.new
browser.open(sf.getdata("URL"))

#**
    #Login
    begin
        id_box = browser.find("input#username") # ID欄
        pass_box = browser.find("input#password") # PASS欄
        login_btn = browser.find("button") # Loginボタン
        
        id_box.send_keys sf.getdata("id")
        pass_box.send_keys sf.getdata("pass")
        login_btn.click
    rescue Selenium::WebDriver::Error::NoSuchElementError
        p '指定された要素が見つかりませんでした'
        browser.close
        return
    rescue => e
        p e.class
        browser.close
        return
    end
    p "ログイン完了"
#*

#**
  # top画面が表示されるのを待ったあと、駐車場選択ボタンを押す
  begin
    #top画面が表示されるまで待つ
    if(browser.wait(browser.finds("div#main_div")))
        park_btn = browser.find("div#ParkChoose")
        park_btn.click 
    else
        p 'ERROR!!'
    end
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end
#**

#**
  # 駐車場一覧を表示させ、駐車場のリンク先を取得
begin
    if !is_fin_loading(browser)
        return
    end
    if !is_fin_tbl_loading(browser)
        return
    end

    #駐車場一覧テーブルから行を取得し、それぞれのページへ遷移する。
    tbl_rows = browser.finds("table#parkChooseTable tbody tr")
    retry_arr = get_parking_data(browser, sf, tbl_rows)

    #取得できなかった駐車場をリトライする
    if(retry_arr.length > 0)
        p "TO DO : Retry datas are here..."
        p retry_arr
        p retry_arr[:obj]

        # get_parking_data(browser, retry_arr[:obj])
    end


    #TODO : 逃避情報のファイルを移動する　


rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
rescue Selenium::WebDriver::Error::TimeoutError
    p 'timeout error!!'
    return
rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
    p "精算機へのアクセス失敗"
    p e
end
#**

p "WORKS ARE ALL DONE."
browser.close