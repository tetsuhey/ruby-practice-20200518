require 'json'

SETTING_FILE_PATH = "./tmp/"
SETTING_FILE_NAME = "setting.json"

class SettingFile
    @sf
    @data = []

    def initialize
        begin
            p 'reading a setting file'
            @sf = JSON.load(File.open(SETTING_FILE_PATH+SETTING_FILE_NAME))    
        rescue => exception
            p "failed to read your setting file"
            p "./tmp/setting.json is exist?"
            return false
        end
    end

    def getdata(attr)
        return @sf[attr]
    end
end