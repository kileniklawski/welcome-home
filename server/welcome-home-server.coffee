Logs = 
Lights = new Mongo.Collection("lights");
HueGroups = new Mongo.Collection("hueGroups");

bridge = {}
bridge.hue_user = "welcomehome"

appInformation = JSON.stringify({
  devicetype: "webApp",
  username: bridge.hue_user
  })

dimmedState = JSON.stringify({
  alert: "none", hue: 15291, effect: "none",
  sat: 123, bri: 110, on: true
})
onState = JSON.stringify({ on: true })
offState = JSON.stringify({ on: false })

Meteor.methods
  getbridgeData: ->
    return Meteor.http.call "GET", "http://www.meethue.com/api/nupnp"

  getHueAPI: ->
    return Meteor.http.call "GET", "http://#{bridge.local_ip}/api/#{bridge.hue_user}"

  testConnection: ->
    test = Meteor.call "getHueAPI"
    if test.data.lights isnt undefined
      return "success"
    else  
      if test.data[0].error.description isnt undefined
        return test.data[0].error.description
      else
        return null

  registerApp: ->
    result = Meteor.http.call "POST", "http://#{bridge.local_ip}/api", { content: appInformation }
    if result.data[0].success isnt undefined
      console.log "Success: The App is now registered"
      Meteor.call "setLightsData"
      Meteor.call "setGroupsData"
    else 
      if result.data[0].error isnt undefined
        console.log "Error found when trying to register App: " + result.data[0].error.description
        return result.data[0].error.description
      return null  

  getLightsData: ->
    return Meteor.http.call "GET", "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights"

  setLightsData: ->
    Meteor.call "getLightsData", (error, results) ->
      if results.data.error isnt undefined
        console.log "%j", results.data.error
        console.log  "Get Lights Data error: #{error.description}"
      else   
        for k,v of results.data
          v.id = k
          Lights.upsert({id: k}, v)

  getGroupsData: ->
    return Meteor.http.call "GET", "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups"

  setGroupsData: ->
    Meteor.call "getGroupsData", (error, results) ->
      if results.data.error isnt undefined
        console.log "%j", results.data.error
        console.log  "Get Groups Data error: #{result}"
      else
        for k,v of results.data
          v.id = k
          HueGroups.upsert({id: k}, v)

  createGroup: (data) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups"
    Meteor.http.call "POST", url, {content: JSON.stringify data}
    Meteor.call "setGroupsData"

  deleteGroup: (id) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}"
    Meteor.http.call "DELETE", url
    HueGroups.remove({id: "#{id}"})
    Meteor.call "setGroupsData"

  modifyGroup: (id, data) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}"
    Meteor.http.call "PUT", url, {content: JSON.stringify data}  
    Meteor.call "setGroupsData"

  groupOn: (id) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}/action"
    Meteor.http.call "PUT", url, { content: onState }
    Meteor.call "setGroupsData"
    Meteor.call "setLightsData"

  groupOff: (id) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}/action"
    Meteor.http.call "PUT", url, { content: offState }
    Meteor.call "setGroupsData"
    Meteor.call "setLightsData"

  groupDimmed: (id) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}/action"
    Meteor.http.call "PUT", url, { content: dimmedState }
    Meteor.call "setGroupsData"
    Meteor.call "setLightsData"

  groupScene: (id, sceneName) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}/action"
    Meteor.http.call "PUT", url, { content: sceneName }
    Meteor.call "setGroupsData"
    Meteor.call "setLightsData"  

  setGroup: (id, data) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/#{id}/action"
    Meteor.http.call "PUT", url, { content: JSON.stringify data.state }
    Meteor.call "setGroupsData"
    Meteor.call "setLightsData"   

  allOn: ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/0/action"
    Meteor.http.call "PUT", url, { content: onState }
    Meteor.call "setLightsData"

  allOff: ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/0/action"
    Meteor.http.call "PUT", url, { content: offState }
    Meteor.call "setLightsData"

  allDimmed: ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/0/action"
    Meteor.http.call "PUT", url, { content: dimmedState }
    Meteor.call "setLightsData"


  bulbOn: (bulb) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{bulb}/state"
    Meteor.http.call "PUT", url, { content: onState }
    Meteor.call "setLightsData"

  bulbOff: (bulb) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{bulb}/state"
    Meteor.http.call "PUT", url, { content: offState }
    Meteor.call "setLightsData"

  bulbDimmed: (bulb) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{bulb}/state"
    Meteor.http.call "PUT", url, { content: dimmedState }
    Meteor.call "setLightsData"

  setBulb: (data) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{data.id}/state"
    Meteor.http.call "PUT", url, { content: JSON.stringify data.state }
    Meteor.call "setLightsData"


Meteor.startup ->

  # We only care about the first connected bridge
  Meteor.call "getbridgeData", (error, results) ->
    bridge.local_ip = results.data[0].internalipaddress
    console.log "Hue bridge found at ip address: #{bridge.local_ip}"
    
    # Is Welcome Home authorized to use the bridge?
    appAllowed = Meteor.call "testConnection"
    if appAllowed is "success"
      console.log "Application registered"
      Meteor.call "setLightsData"
      Meteor.call "setGroupsData"
    else
      console.log "Application message: " + appAllowed

  Meteor.publish "lights", ->
    Lights.find {}

  Meteor.publish "hueGroups", ->
    HueGroups.find {}  
