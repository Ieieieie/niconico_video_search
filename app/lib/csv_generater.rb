require 'csv'
class CsvGenerater
  def self.generate_report(search_keyword, from_time, to_time)
    data = NSearch.recursive_search(search_keyword, from_time, to_time)
    videos = NSearch.filter(data)
    CSV.open('report.csv', 'w') do |csv|
        csv << ["タイトル", "コンテンツID", "再生回数", "コメント数", "マイリスト数&お気に入り数", "コメント+マイリスト/再生回数", "投稿日時"]
        videos.each do |v|
            csv << [v["title"], v["contentId"], v["viewCounter"], v["commentCounter"], v["mylistCounter"], v["view_counter_per_mylist_and_comment_counter"], v["startTime"]]
        end
    end
  end
end