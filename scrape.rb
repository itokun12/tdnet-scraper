require 'nokogiri'
require 'open-uri'
require 'pry'

BASE_URL = 'https://www.release.tdnet.info/inbs/I_list'.freeze
SCRAPE_INTERVAL = 5

def execute
  previous_reports = []

  loop do
    today = Time.now.strftime("%Y%m%d")
    # today = '20190426'

    reports = fetch_all_reports_by_date(today)
    diff_size = reports.size - previous_reports.size

    puts diff_size
    if diff_size > 0
      notify_line(reports, diff_size)
    end

    previous_reports = reports
    sleep(SCRAPE_INTERVAL)
  end
end

def fetch_all_reports_by_date(date)
  reports = []
  page_index = '001'

  loop do
    url = build_url(page_index, date)
    doc = Nokogiri::HTML(open(url))
    reports << doc.css('#main-list-table').css('tr')
    reports.flatten!
    page_index = doc.at_css('.pager-R').attributes['onclick'].value.split('_')[2]
    break unless page_index
  end

  reports
end

def build_url(page_index, date)
  "#{BASE_URL}_#{page_index}_#{date}.html"
end

def notify_line(reports, diff_size)
  # TODO
end

execute
