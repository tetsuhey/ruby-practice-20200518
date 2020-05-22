require 'json'
require 'csv'
require 'fileutils'

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


class DL_Files

    def initialize
        @sf = JSON.load(File.open(SETTING_FILE_PATH+SETTING_FILE_NAME))
        @file_path = @sf["download-dir"]
        date = DateTime.now
        @report_dir_name = date.strftime("%Y%m%d").to_s + "_収集データ"
        unless Dir.exist? (@file_path + @report_dir_name)
            Dir.mkdir(@file_path + @report_dir_name)
        end
    end

    def mv_file_to_dir(p_name, mode)
        # /Downloads/YYYYMMDD_収集データ/PARKING NAME/
        target_dir_name = @file_path + @report_dir_name + "/" + p_name + "/"
        unless Dir.exist? (target_dir_name)
            #駐車場名のフォルダがない場合は作成
            Dir.mkdir(target_dir_name)
        end

        #移動対象のファイル名
        names = File.join(@file_path, mode + "*.pdf") #移動対象のファイル名
        Dir.glob(names).each do |path|
            #駐車場名のフォルダ内に移動する
            File.rename(path, target_dir_name + File.basename(path))
        end
    end
end