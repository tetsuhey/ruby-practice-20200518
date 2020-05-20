require 'selenium-webdriver'

WAIT_TIME = 30
TIME_OUT = 60

#Seleniumライブラリを利用し、Webブラウザを操作する
class Browser

    # Seleniumの初期化
    def initialize
        Selenium::WebDriver.logger.output = File.join("./", "selenium.log")
        Selenium::WebDriver.logger.level = :warn
        @driver = Selenium::WebDriver.for :chrome
        @driver.manage.timeouts.implicit_wait = WAIT_TIME
        @wait = Selenium::WebDriver::Wait.new(:timeout => TIME_OUT)
    end

    #指定された要素を取得しオブジェクトを返す
    #複数の要素が想定される場合はこちらを使う
    def finds(target = nil, iswait = true)
        if(target != nil)
            if(iswait)
                @driver.manage.timeouts.implicit_wait = WAIT_TIME
                return @wait.until{@driver.find_elements(:css => target)}
            else
                @driver.manage.timeouts.implicit_wait = 0
                return @driver.find_elements(:css => target)
            end

        end
    end

    #指定された要素を取得しオブジェクトを返す
    #返すオブジェクトが一つの場合はこちらを使う
    def find(target = nil, iswait = true)
        if(target != nil)
            if(iswait)
                @driver.manage.timeouts.implicit_wait = WAIT_TIME
                elem = @wait.until{@driver.find_element(:css => target)}
            else
                @driver.manage.timeouts.implicit_wait = 0
                elem = @driver.find_element(:css => target)
            end
            
        end
    end
    
    def open(url)
        p url + "　にアクセスします"
        @driver.get(url)
    end

    def close
        @driver.quit
    end

    def wait(obj)
        cnt = 0
        ret = true
        
        loop do
            if(obj.size > 0)
                break
            elsif(cnt >= @timeout)
                p "timeout"
                ret false
                self.close
                break
            elsif(!obj.displayed? || obj.size == 0)
                p "disapper"
                break
            else
                sleep 1
                cnt += 1
                p "ロード中..."
            end
        end
        return ret
    end

    def isExist(target)
        cnt = 0
        cnt = finds(target, false).length.to_i
        if(cnt > 0)
            return true
        else
            return false
        end
    end


    def loading_wait(target)
        timeout = 0
        loop do
            if(isExist(target))
                p "ロード中..."
                sleep 1
                timeout += 1
                if(timeout > TIME_OUT)
                    p "TIME OUT"
                    return false
                    break
                end
            else
                p "ロード終了"
                return true
                break
            end
        end
    end

end


class Elements
    @elem
end