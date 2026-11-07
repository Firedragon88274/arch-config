import spotipy
import sys
from spotipy.oauth2 import SpotifyOAuth
import subprocess
import requests
import json
import time
scope = "user-read-currently-playing"
from dotenv import load_dotenv
import os
env_path = "/home/eric/env/spot.env"
pwd = "/home/eric/.config/hypr/hyprland-config/scripts/queuelauncher"
load_dotenv(dotenv_path=env_path)
client_secret = os.getenv("client_secret")
client_id = os.getenv("client_id")
scope = "user-library-read playlist-read-private"
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    client_id=client_id,
    client_secret=client_secret,
    redirect_uri="http://127.0.0.1:8999",
    scope=scope,
    cache_path="/home/eric/env/spot.cache",
    open_browser=False
))
def downloadimage(url,output_path):
  response = requests.get(url, timeout=20)
  if response.status_code == 200:
      with open(output_path, "wb") as file:
          file.write(response.content)
          #time.sleep(0.5)
      #print("Image downloaded successfully!")
      
  else:
      #print(f"Failed to download image. Status code: {response.status_code}")
      pass

def get_song_info(track):
  song_info = {
        'name': track['name'],
        'artist': track['artists'][0]['name'],
        'album': track['album']['name'],
        'id': track['id'],
        'uri': track['uri'],
        'art': track['album']['images'][0]['url']
    }
  return song_info
def search(query : str,amount : int):
  results = sp.search(q=query, type='track', limit=amount)
  tracks = results['tracks']['items']

  top_songs = []
  for idx, track in enumerate(tracks, start=1):
    info = get_song_info(track)
    info["rank"] = idx
    top_songs.append(info)

  return top_songs
def parse_results(results):
    out = []
    for song in results:
        downloadimage(song["art"], f"{pwd}/img/s{song['rank']}.png")
        formatted_line = f"img:{pwd}/img/s{song['rank']}.png:text:({song['rank']}) {song['name']} - {song['artist']} \uF0CB1                                                     | {song["uri"]}"
        out.append(formatted_line)
    return out
def get_queue(limit):
  queue_data = sp.queue()
  upcoming_tracks = queue_data.get("queue", [])[:limit]
  out = []
  for idx,song in enumerate(upcoming_tracks):
    songi = get_song_info(song)
    songi["rank"] = idx
    downloadimage(songi["art"],f"{pwd}/img/q{idx}.png")
    formatted_line = f"img:{pwd}/img/q{songi['rank']}.png:text:({songi['rank']}) {songi['name']} - {songi['artist']}                                                     | {songi["uri"]}"
    out.append(formatted_line)
  return out
if len(sys.argv) > 1:
    if sys.argv[1] == "search":
        results = parse_results(search(sys.argv[2], int(sys.argv[3]))) # Cast amount to int safely
        for line in results:
            print(line)
            
    if sys.argv[1] == "queue":
        q = get_queue(10)
        for line in q:
          print(line)
          
    if sys.argv[1] == "add":
      uri = sys.argv[2].split("spotify:track:")
      if len(uri) > 1:
          sp.add_to_queue(uri=f"spotify:track:{uri[1]}")
#print(get_queue(10))