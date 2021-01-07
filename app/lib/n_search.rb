require 'json'
require 'csv'
require 'date'

class NSearch
    BASE_URL = "https://api.search.nicovideo.jp/api/v2/snapshot/video/contents/search?"
    items = nil
 
    def self.search(search_keyword, from_time, to_time)
        client = Faraday.new BASE_URL do |b|
            b.request :url_encoded
            b.adapter Faraday.default_adapter
        end
        res = client.get  do |req|
            req.params[:q] = search_keyword
            req.params[:targets] = 'tags'
            req.params[:fields] = 'title,contentId,viewCounter,commentCounter,mylistCounter,startTime'
            req.params[:'filters[startTime][gte]']  = "#{from_time}"
            req.params[:'filters[startTime][lt]']  = "#{to_time}"
            req.params[:'filters[viewCounter][gte]']  = 500
            req.params[:_sort] = 'startTime'
            req.params[:_limit] = 100  
        end
        json = JSON.parse(res.body)
    end

    def self.recursive_search(search_keyword, from_time, to_time)
        data = []
        json = search(search_keyword, from_time, to_time)
        data.concat(json['data'])
        (Date.parse(from_time)..Date.parse(to_time)).select{|d| d.wday == 0}.each do |date|
            json = self.search(search_keyword, date - 7, date)
            data.concat(json['data'])
        end
        data
    end

    def self.filter(data)
        filtered_data = []
        data.each do |d|
            view_counter = d['viewCounter']
            mylist_counter = d['mylistCounter']
            comment_counter = d['commentCounter']
            if view_counter > 0
                view_counter_per_mylist_and_comment_counter = (((comment_counter.to_f + mylist_counter.to_f * 100) / view_counter.to_f)  * 100).floor
                if view_counter_per_mylist_and_comment_counter > 60
                    hash = {}
                    hash["title"] = d['title']
                    hash["contentId"] = 'https://www.nicovideo.jp/watch/' + d['contentId']
                    hash["viewCounter"] = view_counter
                    hash["commentCounter"] = comment_counter
                    hash["mylistCounter"] = mylist_counter
                    hash["view_counter_per_mylist_and_comment_counter"] = view_counter_per_mylist_and_comment_counter
                    hash["startTime"] = d["startTime"]
                    filtered_data << hash
                end
            end
        end
        filtered_data
    end
end