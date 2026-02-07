# Privacy Policy

No metrics are explicitly collected by the widget. The largest privacy impact is the records retained by Cloudflare and the API.  

| Feature | Impact | Reason |
|--------|--------|--------|
| QtLocation libraries | None | Libraries are used for map rendering not geolocation in any way. |
| OpenStreetMap | Requests you make are governed by [OpenStreetMap Foundation's privacy policy](https://osmfoundation.org/wiki/Privacy_Policy)| This is an optional feature that can be used to search for stations. Stations can be searched textually as well. | 
| Cloudflare forwarding | Requests you make are governed by [Cloudflare workers privacy policy](https://workers.cloudflare.com/policies/privacy) | Cloudflare workers are used for throttling/rate-limiting to prevent overages of the underlying API. |
| Wunderground API (IBM Environmental Intelligence Suite) |  Requests you make are governed by [IBM's privacy policy](https://www.ibm.com/us-en/privacy) | The underlying provider for the weather data. |

The relevant personal data that is sent to the API providers are the station ID of your choosing, the coordinates publicly associated with that station, and the locale of your device used to return translated text.



An attempt could likely be made to associate groups of requests with individual users based on the station id, its coordinates, and locale. I do not make that attempt.

I apologize if any part of this makes you uncomfortable. The API was bought out a couple years ago so that put it in the hands of IBM. As a result, I must use Cloudflare to protect usage. 
