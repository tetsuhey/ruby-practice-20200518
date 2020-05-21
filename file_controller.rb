require 'json'
require 'csv'

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

class Error_File_Out_Putter
    def initialize
        @sf = JSON.load(File.open(SETTING_FILE_PATH+SETTING_FILE_NAME))
        @file_path = @sf["download-dir"]
    end

    def out_error_csv(data_hash)
        dt = DateTime.now
        @error_file_name = dt.strftime("%Y%m%d").to_s + "-errors.csv"

        isExist = File.exist?(@file_path + @error_file_name)
        file = nil
        if(isExist)
            file = CSV.open(@file_path + @error_file_name, 'a')
        else
            file = CSV.open(@file_path + @error_file_name, 'w')
            head_txt = ["駐車場名","車室No","逃避台数","逃避金額"]
            file.puts(head_txt)
        end

        p_name = data_hash[:parking]
        td_hash = data_hash[:data].sort_by! {|a| a[:port_num]} #車室番号順にソート
        cnt = 0
        td_hash.each do |dt|
            if(cnt > 0)
                p_name = ""
            end
            file.puts [p_name, dt[:port_num], dt[:num], dt[:amount]]
            cnt += 1
        end
        

        file.close
    end

end