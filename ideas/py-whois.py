#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re
import requests as req
import sys


url = sys.argv[1]
response = req.get(f"https://www.whois.com/whois/{url}")
soup = BeautifulSoup(response.content, "lxml")

souped = soup.select_one('.df-block-raw').text
body = souped.split('Raw Whois Data', 1)

regex = re.compile('Registrant Country: ([a-zA-Z]+)')
res = regex.search(body[1])
print(res.group(1))
