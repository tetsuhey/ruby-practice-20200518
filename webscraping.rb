require 'json'
require 'selenium-webdriver'
require './selenium_controller'


SETTING_FILE_PATH = "./tmp/"
SETTING_FILE_NAME = "setting.json"
YEALY_BTN_CLASS_NAME = "button.yearly-btn" #年報ボタン
MONTHLY_BTN_CLASS_NAME = "button.monthly-btn" #月報ボタン
    
URIAGE_BTN_CLASS_NAME = "button#saleAggreBtn" #売上集計ボタン
SYASHITUBETSU_BTN_CLASS_NAME = "button#roomSaleBtn" #車室別ボタン
JIKANTAI_BTN_CLASS_NAME = "button#timeSaleBtn" #時間帯別ボタン
YOUBI_BTN_CLASS_NAME = "button#dayOfTheWeekSalesBtn" #曜日別ボタン
CYUSYAJIKAN_BTN_CLASS_NAME = "button#timeAmountBtn" #駐車時間帯別ボタン

SYUKEIBI_Y_START_TXT_CLASS_NAME = "input#chooseOneMonI" #集計開始日選択(年報)
SYUKEIBI_M_START_TXT_CLASS_NAME = "input#chooseOneMonI" #集計開始日選択(月報)
SEIKYU_BTN_CLASS_NAME = "input#requestInput" #請求ボタン

SHOW_GRAPH_BTN_CLASS_NAME = "button#graphButton" #グラフ表示ボタン

#**
    #設定ファイルを読み込む
    begin
        sf = JSON.load(File.open(SETTING_FILE_PATH+SETTING_FILE_NAME))
        if(sf == nil)
            p "setting file could not read"
            return
        end
    rescue
        p "could not find your setting file"
        return
    end
#**

@wait_time = 10
@timeout = 60
# Seleniumの初期化
# class ref: https://www.rubydoc.info/gems/selenium-webdriver/Selenium/WebDriver/Chrome
Selenium::WebDriver.logger.output = File.join("./", "selenium.log")
Selenium::WebDriver.logger.level = :warn
driver = Selenium::WebDriver.for :chrome
driver.manage.timeouts.implicit_wait = @timeout
wait_reading = Selenium::WebDriver::Wait.new(timeout: @wait_time)
p driver.manage.timeouts

# Yahooを開く
driver.get(sf["URL"])
return
driver.quit
#**
  # 検索欄/検索ボタン取得
  begin
    id_box = driver.find_element(:id, 'username') # ID欄
    pass_box = driver.find_element(:id, 'password') # PASS欄
    login_btn = driver.find_element(:tag_name, 'button') # Loginボタン
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end

  # idとパスワードを入力しログインする
  id_box.send_keys sf["id"]
  pass_box.send_keys sf["pass"]
  login_btn.click
#**


#**
  # 始めの駐車場データを取得
  
  begin
    sleep 1
    parking_select_btn = driver.find_element(:id, 'ParkChoose') # 駐車場選択ボタン
    parking_select_btn.click
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end

#**
    #駐車場ページ内での操作を実行する
    def gotoparking (d, w)
        
        p "集計ボタンクリック"
        agregate_btn = w.until{d.find_element(:id => "aggregateBtn")}
        agregate_btn.click #集計ボタンクリック

        sleep 3
        p "年報ボタンクリック"
        #年報の売上ボタンを表示
        yearly_btn = w.until{d.find_element(:css => YEALY_BTN_CLASS_NAME)}
        yearly_btn.click #年報ボタンクリック
        sleep 1

        #売上集計ボタンをクリック
        p "売上集計ボタンクリック"
        uriage_btn = w.until{d.find_element(:css => URIAGE_BTN_CLASS_NAME)}
        uriage_btn.click
        sleep 1

        #請求開始の日付を入力
        p "日付入力"
        date_input = w.until{d.find_element(:css => SYUKEIBI_Y_START_TXT_CLASS_NAME)}
        date_input.send_keys("2020/01")
        sleep 1

        #請求にチェック
        p "請求にチェック"
        unless w.until{d.find_element(:css => SEIKYU_BTN_CLASS_NAME).selected?}
            p "請求にチェック"
            seikyu_chk = d.find_element(:css => SEIKYU_BTN_CLASS_NAME).click
        end
        sleep 1

        #グラフ表示ボタンクリック
        p "グラフ表示"
        show_btn = w.until{d.find_element(:css => SHOW_GRAPH_BTN_CLASS_NAME)}
        show_btn.click

        #保存ボタンを探す
        sleep 2
        btns = w.until{d.find_elements(:css => "button.btn")}
        btns.each do |btn|
            attr = btn.attribute("onclick")
            if(attr == "savePDF()")
                p "PDF出力"
                btn.click #download フォルダにPDF格納
                break
            end
        end

        sleep 3
    end
#**

#**
  # 始めの駐車場データを取得
  begin
    sleep 1
    parking_rows = driver.find_elements(:css => "table#parkChooseTable tbody tr")
    # 始めの駐車場データを取得
    pr = parking_rows[0].find_element(:css => "td.sorting_1 a")
    pr.click
    p pr.text.encode('UTF-8') + "をクリック"
    
    # 読み込みをまつ
    sleep 3
    loading_elem = driver.find_element(:css => "div.loading-outter")
    cnt = 0
    loop do
        if(loading_elem.displayed?)
            sleep 3
            cnt += 1
            p "ロード中..."
            if(cnt > 5)
                break
            end
        end
    end
  rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
    #ロード終了のトリガーがないので、例外処理=ロード終了とする
    #loding_elemがDOMから消えた際にここが呼ばれる
    p "Loading 終了"
    gotoparking(driver, wait_reading)
    p "終了"

  rescue => e
    p e.class
    p "-----------"
  end

  # idとパスワードを入力しログインする
  #parking_select_btn.click
#**

# ドライバーを閉じる
driver.quit