#!/usr/bin/env python3


'''
Find in what country a given IP is hosted in.
'''


from bs4 import BeautifulSoup
import re
import requests
import sys


url = sys.argv[1]

response = requests.get(f'https://www.whois.com/whois/{url}')
soup = BeautifulSoup(response.content, 'lxml')
souped = soup.select_one('pre', attrs={'id': 'registryData'})
regex = re.compile('country:\s*([a-zA-Z]+)', re.IGNORECASE)
res = regex.search(str(souped))
print(res.group(1))

