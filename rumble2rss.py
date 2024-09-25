from bottle import route, run
import requests
import sys
from bs4 import BeautifulSoup
from feedgen.feed import FeedGenerator
from datetime import datetime
from bottle import route, request, response, template
from urllib.parse import urlparse
# pip3 install bottle requests bs4 feedgen cheroot

@route('/hello')
def hello():

    return 'true' if is_absolute_url(request.query.url) else 'false'

    # for key in request.query:
    #     string += str(key) + ':' + request.query[key] + ' '
    # return string

    now = datetime.now()
    return now.strftime("%H:%M:%S")

@route('/')
def main():

    target_url = request.query.url
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0"
    }
    req = requests.get(target_url, headers=headers)

    html_doc = req.text

    soup = BeautifulSoup(html_doc, 'html.parser')
    video_items = soup.find_all("div", class_="videostream thumbnail__grid--item")

    feed = FeedGenerator()
    feed_title = soup.find('div', class_='channel-header--title').find('h1').text
    feed.title(feed_title + ' - Rumble2RSS')

    feed.generator('Rumble2RSS')

    feed.link(href=target_url)
    feed.description(feed_title)

    for video_item in video_items:
 
        title = video_item.find(class_="title__link link").text.strip()
        rel_url = video_item.find(class_="title__link link").get('href')
        abs_url = 'http://rumble.com' + rel_url
        date_string = video_item.find(class_="videostream__data--subitem videostream__time").get('datetime')
        date_string_without_colon = date_string[:-3] + date_string[-2:] # we remove this colon manually becasue strptime can't deal with it

        date_format = "%Y-%m-%dT%H:%M:%S%z"
        date_object = datetime.strptime(date_string_without_colon, date_format)
        
        img = video_item.find(class_="thumbnail__image")

        entry = feed.add_entry(order='append')
        entry.title(title)
        entry.link(href=abs_url)  # Construct the full link   
        entry.published(date_object)
        entry.description(title)
    
    rss_feed = feed.rss_str(pretty=True)
    response.headers['Content-Type'] = 'application/rss+xml; charset=UTF-8'
    return rss_feed


def is_absolute_url(url):
    return bool(urlparse(url).netloc == 'rumble.com')

    x = urlparse(url)
    print(x)

    print(urlparse(url).netloc)

    return bool(urlparse(url).netloc)

run(host='localhost', port=8555, debug=True, server='cheroot')



