require 'json'
require 'selenium-webdriver'

SETTING_FILE_PATH = "./tmp/"
SETTING_FILE_NAME = "setting.json"

def read(path)
    file = File.open(path)
    if(file == nil)
        return nil
    else
        return JSON.load(file)
    end
end


sf = read(SETTING_FILE_PATH+SETTING_FILE_NAME)
if(sf == nil)
    p "setting file could not read"
    return
end

url = sf["URL"]
login_id = sf["id"]
login_pass = sf["pass"]
dl_file_name = sf["target_file_name"]
dl_dir = SETTING_FILE_PATH


@wait_time = 3
@timeout = 4
# Seleniumの初期化
# class ref: https://www.rubydoc.info/gems/selenium-webdriver/Selenium/WebDriver/Chrome
Selenium::WebDriver.logger.output = File.join("./", "selenium.log")
Selenium::WebDriver.logger.level = :warn
driver = Selenium::WebDriver.for :chrome
driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

# Yahooを開く
driver.get(sf["URL"])

# ちゃんと開けているか確認するため、sleepを入れる
sleep 0

#**
  # ブラウザでさせたい動作を記載する
  # ex. 検索欄に'Ruby'と入力して、検索ボタンを押す処理
  # 検索欄/検索ボタン取得
  begin
    id_box = driver.find_element(:id, 'username') # 検索欄
    pass_box = driver.find_element(:id, 'password') # 検索欄
    search_btn = driver.find_element(:tag_name, 'button') # 検索ボタン
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end

  # idとパスワードを入力しログインする
  id_box.send_keys sf["id"]
  pass_box.send_keys sf["pass"]
  search_btn.click
#**


#**
  # 始めの駐車場データを取得
  
  begin
    sleep 3
    parking_select_btn = driver.find_element(:id, 'ParkChoose') # 駐車場選択ボタン
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end

  parking_select_btn.click
#**

#**
  # 始めの駐車場データを取得
  
  begin
    parking_rows = driver.find_element(:id, 'parkChooseTable').find_elements(:tag_name, "tr") # 駐車場一覧
    p parking_rows.length
    p parking_rows.instance_methods(false)
    parking_rows.each do |parking|
        
    end

  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end

  # idとパスワードを入力しログインする
  #parking_select_btn.click
#**

# ドライバーを閉じる
driver.quit