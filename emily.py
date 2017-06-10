import urllib.request
import urllib
import re

def scrapWebsite(letter):
    req = urllib.request.Request("http://www.basenotes.net/bn_letter.php?i="+letter, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req).read()

    # Finds all links on the page
    arrayofLinks = re.findall('(?<=href=").*?(?=")', str(html), re.I)

    for i in arrayofLinks:
        # Only find ones with "ID" in them
        if i[1:3] == "ID":
            singlePageScrape(i)


def singlePageScrape(URL):
    print("------")

    req = urllib.request.Request("http://www.basenotes.net"+URL, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req).read()

    # finds all things that have the class "notespyramid notespyramidb" -- turns them into an array.
    # Only one these things on the page atm

    pyramidContentArray = re.findall('<div\s+class=\"notespyramid notespyramidb\">.*?</div>', str(html), re.I)

    pyramidContentArray_pyramid = re.findall('<ol>.*?</ol>', str(html), re.I)
    pyramidContentArray_topNotes = re.findall('<li>.*?</li>', str(pyramidContentArray_pyramid[0]), re.I)

    counter = 0

    for elem in pyramidContentArray_topNotes:

        # If we find Top Notes, then use everything within the li's
        if "Top Notes" in elem:
            counter = 1
        elif "Heart Notes" in elem:
            counter = 0
        elif counter == 1:
            shortLink = re.findall('<a[^>]*>(.*?)</a>', str(elem), re.I)
            print("Top Note: ",shortLink[0])

# We can loop over this with every letter in the a,b,c..
scrapWebsite("a")