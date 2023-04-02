# pylint: disable=missing-module-docstring

import sys
import urllib.parse
import requests

BASE_URI = "https://weather.lewagon.com"
#base_url: "https://weather.lewagon.com/geo/1.0/direct"

def search_city(query):
    '''Look for a given city. If multiple options are returned, have the user choose between them.
       Return one city (or None)
    '''
    # url = BASE_URI + "/geo/1.0/direct?q=" + query
    # response = requests.get(url).json()
    url = urllib.parse.urljoin(BASE_URI, "/geo/1.0/direct")
    response = requests.get(url, params={'q': query, 'limit': 5}).json()

    if not response:
        print(f"Sorry, metaweather does not konw {query}...")
        return None

    if len(response) == 1:
      return response[0]
    for i, city in enumerate(response):
        print(f"{i + 1}. {response[i]['name']},{response[i]['country']}")
    index = int(input("Multiple matches found, which city did you mean?\n> ")) - 1
    return response[index]


def weather_forecast(lat, lon):
    '''Return a 5-day weather forecast for the city, given its latitude and longitude.'''
    url = urllib.parse.urljoin(BASE_URI, "/data/2.5/forecast")
    forecasts = requests.get(url, params={'lat': lat, 'lon': lon, 'units': 'metric'}).json()['list']
    return forecasts[::8]

def main():
    '''Ask user for a city and display weather forecast'''
    query = input("City?\n> ")
    place = search_city(query)
    # TODO: Display weather forecast for a given city
    if place:
        forecast = weather_forecast(place['lat'], place['lon'])
        print(f"Weather forecast for {place['name']}, {place['country']}:\n")

        for cities in forecast:
            date = cities['dt_txt'].split()[0]
            time = cities['dt_txt'].split()[1][:-3]
            temp = cities['main']['temp']
            desc = cities['weather'][0]['description']
            print(f"{date} {time}: {temp:.1f}°C, {desc}")
        print()

if __name__ == '__main__':
    try:
        while True:
            main()
    except KeyboardInterrupt:
        print('\nGoodbye!')
        sys.exit(0)


# if place:
#         forecast = weather_forecast(place['lat'], place['lon'])
#         print(f"5-Day Weather Forecast for {place['name']}, {place['country']}:\n")
#         for i, day in enumerate(forecast):
#             date = datetime.datetime.strptime(day['dt_txt'], '%Y-%m-%d %H:%M:%S').strftime('%A, %B %d')
#             temp = round(day['main']['temp'])
#             description = day['weather'][0]['description']
#             print(f"{date}: {temp}°C, {description}")
#     else:
#         print("No matching city found. Please try again.")
