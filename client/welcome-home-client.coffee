Lights = new Mongo.Collection("lights")
Meteor.subscribe("lights")
HueGroups = new Mongo.Collection("hueGroups")
Meteor.subscribe("hueGroups")

Session.set("currentPage", "lightList")
Session.set("currentBulb", null)
Session.set("currentGroup", null)

Template.body.helpers
  currentPage: ->
    return Session.get("currentPage")

Template.body.events
  'click header h1': ->
    Session.set("currentBulb", null)
    Session.set("currentPage", "lightList")

  'click a.all-on': (evt) ->
    evt.preventDefault()
    Meteor.call 'allOn'

  'click a.all-off': (evt) ->
    evt.preventDefault()
    Meteor.call 'allOff'

  'click a.all-default': (evt) ->
    evt.preventDefault()
    Meteor.call 'allDefault'

  'click #light-list div': (evt) ->
    evt.preventDefault()
    Session.set("currentBulb", this.id)
    Session.set("currentPage", "bulbPanel")
  
  'click a.hue-groups': (evt) ->
    Session.set("currentPage", "hueGroupsList")    

Template.lightList.helpers
  lights: ->
    return Lights.find({}, {sort: {name: 1}})


Template.bulbPanel.helpers
  bulb: ->
    return Lights.findOne( {id: Session.get("currentBulb")})

Template.bulbPanel.events
  'change input[type=range]': ->
    data = {
      id: Session.get "currentBulb"
      state: {
        hue: parseInt($('.hue-range').val(), 10)
        sat: parseInt($('.saturation-range').val(), 10)
        bri: parseInt($('.brightness-range').val(), 10)
      }
    }
    Meteor.call "setBulb", data

  'click a.bulb-on': (evt) ->
    evt.preventDefault()
    Meteor.call "bulbOn", Session.get("currentBulb")

  'click a.bulb-off': (evt) ->
    evt.preventDefault()
    Meteor.call "bulbOff", Session.get("currentBulb")

  'click a.bulb-default': (evt) ->
    evt.preventDefault()
    Meteor.call "bulbDefault", Session.get("currentBulb")
  'click a.bulb-close': (evt) ->
    Session.set("currentBulb", null)
    Session.set("currentPage", "lightList")

Template.hueGroupsList.helpers
  hueGroups: ->
    return HueGroups.find({}, {sort: {name: 1}})

Template.hueGroupsList.events
  'click a.return-home': (evt) ->
    evt.preventDefault()
    Session.set("currentPage", "lightList")
  'click a.new-group': (evt) ->
    evt.preventDefault()
    Session.set("currentPage", "hueForm")
  'click a.edit-group': (evt) ->
    evt.preventDefault()
    Session.set("currentPage", "hueForm")
    Session.set("currentGroup", this.id)
    console.log ("Setting currentGroup to: " + Session.get("currentGroup"))


Template.hueForm.helpers
  group: ->
    return HueGroups.findOne( {id: Session.get("currentGroup")} )
  lights: ->
    return Lights.find({}, {sort: {name: 1}})
  hasLight: ->
    if Session.get("currentGroup") isnt null
      g = HueGroups.findOne( {id: Session.get("currentGroup")} )
      console.log ( "ID " + this.id + " Name " + this.name + " GL " + g.lights + " Session: " + Session.get("currentGroup"))
      return if _.contains(g.lights, this.id) then 'checked' else ''
    else
      return ""  

Template.hueForm.events
  'click a.submit-group': (evt, template) ->
    evt.preventDefault()
    groupName = template.find("input[type=text]") ? ""

    if groupName.value isnt ""
      console.log("GroupName: " + groupName.value)
      console.log("%j", groupName)
      bulbsSelected = template.findAll( "input[type=checkbox]:checked")
      bulbsArray = _.map bulbsSelected, (item) -> item.id
      console.log("ID " + Session.get("currentGroup"))
      console.log(bulbsArray);
      # console.log ("Lights[]: " + bulbsSelected)
      console.log("%j", bulbsSelected)
      data = {
        name: groupName.value
        lights: bulbsArray
      }
      console.log("%j", data)
      if Session.get("currentGroup") isnt null
        console.log("Call Modify - Group ID" + Session.get("currentGroup"))
        Meteor.call "modifyGroup", Session.get("currentGroup"), data
      else
        console.log("Call New")
        Meteor.call "createGroup", data
      evt.preventDefault()
      Session.set("currentGroup", null)
      Session.set("currentPage", "hueGroupsList")
    else
      console.log("Empty Name")

  'click a.cancel': (evt) ->
    evt.preventDefault()
    Session.set("currentGroup", null)
    Session.set("currentPage", "lightList")    