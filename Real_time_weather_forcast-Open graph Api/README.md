## Weather forecast for the next five days

For this project I will be using the [OpenWeatherMap API documentation](https://openweathermap.org/api)

APIs is a common way of collecting data. It can be [public APIs](https://github.com/public-apis/public-apis) with authentication or not, free or paid, or internal APIs at your company, etc.

First, Sign up for an API key (which might take 10-20 minutes to get activated)
Next, go through hthe API documentation to find the specific URL needed.

Second, Making a test call to the API using a browser to make sure we don't start coding too much before realizing that the API is not a good fit for our required purpose.

If you are on Chrome, you should install the [JSONView](https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc) extension for a neater look. In the end, JSON is just text that needs to be **parsed**, that's what the extension will do.





### Using Python

Finally, we want to use this API in _our code_. with the simple HTTP library for Python [`requests`](https://requests.readthedocs.io).





### Weather CLI

Let's build a weather [CLI](https://en.wikipedia.org/wiki/Command-line_interface) using the API. Here's the flow for a user (pseudo-code!):
This will be achieved by implementing 3 functions.

1. Launch the app with `python weather.py`
2. Get asked to type a city name
3. If city is unknown to the API, display an error message and go back to step 2.
4. Fetch the weather forecast for the next 5 days and display it (Date, Weather and max temperature in °C)
5. Go back to step 2 (loop to ask for a new city).
6. At any point, `Ctrl`-`C` can be used to quit the program

In action, it should look like this:

```bash
python weather.py
```

```text
City?
> london
Here's the weather in London
2020-09-30: Heavy Rain 16.4°C
2020-10-01: Light Rain 15.1°C
2020-10-02: Heavy Rain 13.4°C
2020-10-03: Heavy Rain 14.3°C
2020-10-04: Heavy Rain 14.6°C
City?
>
```

If the user input is ambiguous (i.e. several cities come back from the search), display them and ask the user to pick one by index, like this:

```text
City?
> Pari
1. Paris,FR
2. Paris,FR
3. Paris,FR
4. Pari,IT
5. Puri,IN
Multiple matches found, which city did you mean?
> 1
2022-09-26: Clouds (12°C)
2022-09-27: Clouds (10°C)
2022-09-28: Rain (12°C)
2022-09-29: Clouds (11°C)
2022-09-30: Clear (10°C)
```

(
