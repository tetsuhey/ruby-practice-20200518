require './selenium_controller'
require './file_controller'
require './parkingdata'

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
    if(browser.wait(browser.finds("table#parkChooseTable")))
        retry_arr = []
        browser.finds("table#parkChooseTable tbody tr td.sorting_1 a").each do |park_row|
            p park_row.text.encode('UTF-8') + "をクリック"
            park_row.click

            if(browser.find("div.loading-outter"))
                if(browser.loading_wait("div.loading-outter"))
                    p "集計ボタンクリック"
                    browser.find("a#aggregateBtn").click #集計ボタンクリック

                    pe = ParkingElems.new(browser)
                    attr = {date:"2020/01"}
                    p "年報売上収集開始"
                    pe.getNenpou(attr)
                    sleep 2
                    browser.find("a#aggregateBtn").click #集計ボタンクリック

                    attr = {date:"2020/04/01", mode:"売上"}
                    p "月報売上収集開始"
                    pe.getGeppou(attr)
                    sleep 2
                    browser.find("a#aggregateBtn").click #集計ボタンクリック

                    attr = {date:"2020/04/01", mode:"車室"}
                    p "車室別収集開始"
                    pe.getGeppou(attr)
                    sleep 2
                    browser.find("a#aggregateBtn").click #集計ボタンクリック

                    attr = {date:"2020/04/01", mode:"時間帯"}
                    p "時間帯別収集開始"
                    pe.getGeppou(attr)
                    sleep 2
                    browser.find("a#aggregateBtn").click #集計ボタンクリック

                    attr = {date:"2020/04/01", mode:"曜日"}
                    p "曜日別収集開始"
                    pe.getGeppou(attr)
                    sleep 2
                    browser.find("a#aggregateBtn").click #集計ボタンクリック

                    attr = {date:"2020/04/01", mode:"駐車時間"}
                    p "駐車時間別収集開始"
                    pe.getGeppou(attr)
                    sleep 2
                else
                    #timeoutになった行はリトライする配列へ
                    retry_arr << {name: park_row.text.encode('UTF-8'), obj: park_row}
                end
            end

            break #TOBE DELETE
        end
    else
        p 'ERROR!!'
        #top = browser.wait.until {browser.find("div#main_div").displayed?} # トップ画面
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