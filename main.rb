require './selenium_controller'
require './file_controller'
require './parkingdata'

def is_fin_loading(b)
    if(!b.isExist("div.loading-outter"))
        return true
    end
    if(b.loading_wait("div.loading-outter"))
        return true
    else
        p "time out to loading"
        browser.close
        return false
    end
end

def is_fin_tbl_loading(b)
    if(b.isExist("table#parkChooseTable tbody tr td.sorting_1 a"))
        return true
    end
    if(b.loading_wait("table#parkChooseTable tbody tr td.sorting_1 a"))
        return true
    else
        p "time out to loading"
        browser.close
        return false
    end
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

    retry_arr = []

    #駐車場一覧テーブルから行を取得し、それぞれのページへ遷移する。
    tbl_rows = browser.finds("table#parkChooseTable tbody tr")
    
    for index in 0..(tbl_rows.length - 1)
        
        park_row = tbl_rows[index]
        
        #出力対象外はスキップ
        if(!browser.find_target_row(park_row, "WS"))
            next
        end

        #フラップ式の駐車場とゲート式を区別
        isFlap = browser.find_target_row(park_row, "フラップ")

        #各駐車場のページに遷移
        park_link = browser.get_child_obj("td.sorting_1 a", park_row)
        p_name = park_link.text.encode('UTF-8')
        p p_name + "をクリック"
        park_link.click

        # 接続できないモーダルがある場合はリトライする
        if browser.isDisplayed("div.modal")
            p "time out to loading"
            #接続できなかった行はリトライする配列へ
            retry_arr << {name: p_name, obj: park_row}
            next
        end

        # loadingを待つ
        if !is_fin_loading(browser)
            p "time out to loading"
            #timeoutになった行はリトライする配列へ
            retry_arr << {name: p_name, obj: park_row}
            next
        end

        #駐車場のページからPDFを取得する
        pe = ParkingElems.new(browser, isFlap, p_name)
        attr = {}
        
        #p "年報売上収集開始"
        attr = {date:sf.getdata("target-m")}
        #pe.getNenpou(attr)
        
        #p "月報売上収集開始"
        attr = {date:sf.getdata("target-d"), mode:"売上"}
        #pe.getGeppou(attr)
        
        p "車室別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"車室"}
        pe.getGeppou(attr)
        
        #p "時間帯別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"時間帯"}
        #pe.getGeppou(attr)    
        
        #p "曜日別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"曜日"}
        #pe.getGeppou(attr)
        
        #p "駐車時間別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"駐車時間"}
        #pe.getGeppou(attr)

        #p "サービス券情報収集開始"
        attr = {date:sf.getdata("target-d"), mode:"サービス情報"}
        #pe.getGeppou(attr)

        p p_name + "の処理を終了"

        if(index != (tbl_rows.length - 1))
            #ブラウザをリフレッシュ
            browser.reflesh
            #ロードを待機
            is_fin_loading(browser)

            #**  
                # 一度トップ画面に戻ると、フロント側でセッションを再設定する仕様のため
                # もう一度要素を再取得する
                
                #駐車場一覧ボタンをクリック
                browser.find("div#ParkChoose").click

                #ロードを待機
                unless is_fin_loading(browser)
                    return
                end
                unless is_fin_tbl_loading(browser)
                    return
                end

                # 駐車場一覧テーブルを再取得
                tbl_rows = browser.finds("table#parkChooseTable tbody tr")
            #**
        end
        #break
    end

    #取得できなかった駐車場をリトライする
    if(retry_arr.length > 0)
        p "TO DO : Retry datas are here..."
        p retry_arr
    end

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