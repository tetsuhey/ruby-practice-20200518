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
        p "time out to loading"
        browser.close
        return
    end
    if !browser.wait(browser.finds("table#parkChooseTable tbody tr td.sorting_1 a"))
        p "time out to read"
        browser.close
        return
    end

    retry_arr = []

    #駐車場一覧テーブルから行を取得し、それぞれのページへ遷移する。
    browser.finds("table#parkChooseTable tbody tr").each do |park_row|
        #出力対象外はスキップ
        if(!browser.find_target_row(park_row, "WS"))
            next
        end

        #フラップ式の駐車場とゲート式を区別
        isFlap = browser.find_target_row(park_row, "フラップ")

        #各駐車場のページに遷移
        park_link = browser.get_child_obj("td.sorting_1 a", park_row)
        p park_link.text.encode('UTF-8') + "をクリック"
        park_link.click

        # loadingを待つ
        if !is_fin_loading(browser)
            p "time out to loading"
            #timeoutになった行はリトライする配列へ
            retry_arr << {name: park_link.text.encode('UTF-8'), obj: park_row}
            next
        end

        #駐車場のページからPDFを取得する
        pe = ParkingElems.new(browser, isFlap)
        attr = {}
        
        p "年報売上収集開始"
        attr = {date:sf.getdata("target-m")}
        pe.getNenpou(attr)
        
        p "月報売上収集開始"
        attr = {date:sf.getdata("target-d"), mode:"売上"}
        pe.getGeppou(attr)
        
        p "車室別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"車室"}
        pe.getGeppou(attr)
        
        p "時間帯別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"時間帯"}
        pe.getGeppou(attr)    
        
        p "曜日別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"曜日"}
        pe.getGeppou(attr)
        
        p "駐車時間別収集開始"
        attr = {date:sf.getdata("target-d"), mode:"駐車時間"}
        pe.getGeppou(attr)

        p "サービス券情報収集開始"
        attr = {date:sf.getdata("target-d"), mode:"サービス情報"}
        pe.getGeppou(attr)


        break #TOBE DELETE
    end
rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
rescue Selenium::WebDriver::Error::TimeoutError
    p 'timeout error!!'
    return
end
#**
sleep 10
browser.close