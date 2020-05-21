require './report_file_creator'

class Parking_Error_File

    def initialize(browser, p_name)
        @browser = browser
        @parking_name = p_name
        @out_arr = {parking:p_name, data:[]}
    end

    def errorChk
        if(!@browser.loading_wait("div.loading-outter"))
            return false
        end

        trs = @browser.finds("table#cabinTable tbody tr") #車室別テーブル
        data_row = []

        trs.each do |tr|
            tds = tr.find_elements(:tag_name => "td")
            
            key_td1 = tds[0] == nil ? "" : tds[0].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
            key_td2 = tds[6] == nil ? "" : tds[6].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
            key_td3 = tds[12] == nil ? "" : tds[12].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")

            if(key_td1.length > 0)
                error_car_amount = tds[4].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
                error_car_num = tds[5].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
                data_row << {
                    port_num:key_td1,
                    amount:error_car_amount,
                    num:error_car_num
                }   
            end     
            if(key_td2.length > 0)
                error_car_amount = tds[10].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
                error_car_num = tds[11].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
                data_row << {
                    port_num:key_td2,
                    amount:error_car_amount,
                    num:error_car_num
                }
            end
            if(key_td3.length > 0)
                error_car_amount = tds[16].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
                error_car_num = tds[17].attribute("textContent").to_s.gsub(" ","").gsub("\n", "")
                data_row << {
                    port_num:key_td3,
                    amount:error_car_amount,
                    num:error_car_num
                }
            end
        end

        data_row.each do |row|
            if(row[:num].split("台")[0].to_i > 0 && row[:amount].split("¥")[1].to_i > 0)
                p "find! Error!!"
                @out_arr[:data] << row
            end
        end

        if(@out_arr[:data].length > 0)
            p @out_arr
            error_file = Error_File_Out_Putter.new
            error_file.out_error_csv(@out_arr)
            return true
        else
            return false
        end

    end
    
end