require 'json'

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

