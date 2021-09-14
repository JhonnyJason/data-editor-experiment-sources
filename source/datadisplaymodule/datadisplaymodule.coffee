datadisplaymodule = {name: "datadisplaymodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["datadisplaymodule"]?  then console.log "[datadisplaymodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
# interact = require("interactjs")
dataEdit = null
state = null

############################################################
lineNumber = 0
topDistance = 50
rectPadding = 10
data = null

mode = "undecided"
activeTarget = null
isInMove = false
initialX = 0
initialY = 0
initialTX = 0
initialTY = 0


############################################################
datadisplaymodule.initialize = ->
    log "datadisplaymodule.initialize"
    dataEdit = allModules.dataeditmodule
    state = allModules.statemodule
    data = state.load("data")
    state.setChangeDetectionFunction("data", () -> true)
    olog data
    
    datadisplaymodule.displayData()
    initDisplayEvents()
    return

############################################################
createDataPoint = (data, id) ->
    log "createDataPoint"
    
    olog data
    
    label = data.label
    content = data.content
    meta = data.meta

    g = document.createElementNS("http://www.w3.org/2000/svg", "g")
    datadisplay.appendChild(g)


    text = document.createElementNS("http://www.w3.org/2000/svg", "text")
    text.textContent = label
    
    if meta? and meta.x? then text.setAttributeNS(null, "x", meta.x)
    else text.setAttributeNS(null, "x", 50)

    if meta? and meta.y? then text.setAttributeNS(null, "y", meta.y)
    else text.setAttributeNS(null, "y", lineNumber * topDistance + topDistance)
    lineNumber++

    g.appendChild(text)

    bBox = text.getBBox()
    rect = document.createElementNS("http://www.w3.org/2000/svg", "rect")
    rect.setAttributeNS(null, "x", bBox.x - rectPadding)
    rect.setAttributeNS(null, "y", bBox.y - rectPadding)
    rect.setAttributeNS(null, "rx", 5)
    rect.setAttributeNS(null, "ry", 5)    
    rect.setAttributeNS(null, "width", bBox.width + 2 * rectPadding)
    rect.setAttributeNS(null, "height", bBox.height + 2 * rectPadding)
    
    g.prepend(rect)
    transform = getTransformString(meta)
    g.setAttributeNS(null, "transform", transform)
    g.setAttributeNS(null, "data-id", id)
    initEvents(g)
    return

initEvents = (el) ->
    el.addEventListener("mousedown", mouseDowned)
    # el.addEventListener("touchstart", touchStarted)
    el.addEventListener("click", elementClicked)
    return

initDisplayEvents = ->
    datadisplay.addEventListener("mouseup", mouseUpped)
    # datadisplay.addEventListener("touchend", touchEnded)
    datadisplay.addEventListener("mousemove", mouseMoved)
    # datadisplay.addEventListener("touchmove", touchMoved)
    # datadisplay.addEventListener("mouseleave", mouseLeft)
    # datadisplay.addEventListener("touchcancel", touchCancelled)
    return

getGroupNode = (target) ->
    counter = 5
    while target.nodeName != "g"
        target = target.parentNode
        counter--
        if !counter then throw new Error("Did not find group node as parents...")
    return target

printState = ->
    if !activeTarget? then label = undefined
    else label = activeTarget.textContent
    log "- - - - - -"
    olog {
        mode,
        label,
        isInMove,
        initialX, 
        initialY,
        initialTX,
        initialTY
    }
    log "- - - - - -"
    return

resetState = ->
    log "resetState"
    mode = "undecided"
    activeTarget = null
    isInMove = false
    initialX = 0
    initialY = 0
    initialTX = 0
    initialTY = 0
    return

getMousePosition = (evt) ->
    ctm = datadisplay.getScreenCTM()
    position = 
        x: (evt.clientX - ctm.e) / ctm.a
        y: (evt.clientY - ctm.f) / ctm.d
    return position

resetTransform = ->
    if isInMove and activeTarget?
        transform = "translate("+initialTransformX+" "+initialTransformY")"
        activeTarget.setAttributeNS(null, "transform", transform)
    return

saveTransform = ->
    log "saveTransform"
    if isInMove and activeTarget?
        tCoords = getTranslateCoordinates(activeTarget)
        id  = getDataID(activeTarget)
        data[id].meta.tx = tCoords.tx
        data[id].meta.ty = tCoords.ty
        state.save("data", data, false)
    return

getDataID = (target) ->
    log "getDataID"
    idString = target.getAttributeNS(null, "data-id")
    return parseInt(idString)

getTranslateCoordinates = (target) ->
    log "getTranslateCoordinates"
    transformString = target.getAttributeNS(null, "transform")
    tx = 0
    ty = 0
    if !transformString then return {tx, ty}
    # log transformString
    
    startKey = "translate("
    lKey = startKey.length
    indexStart = transformString.indexOf(startKey)
    if indexStart < 0 then return {tx, ty}

    transformString = transformString.slice(indexStart+lKey)
    # log transformString
    indexEnd = transformString.indexOf(")")
    transformString = transformString.slice(0,indexEnd)
    # log transformString
    tokens = transformString.split(" ")
    tx = parseFloat(tokens[0])
    ty = parseFloat(tokens[1])
    return {tx, ty}

getTransformString = (meta) ->
    log "getTransformString"
    if meta.tx? then tx = meta.tx
    else tx = 0
    if meta.ty? then ty = meta.ty
    else ty = 0
    return "translate("+tx+" "+ty+")"
############################################################
#region eventListeners
mouseDowned = (evt) ->
    log "mouseDowned"
    evt.preventDefault()
    target = getGroupNode(evt.target)
    mode = "mouse"
    activeTarget = target
    mousePosition = getMousePosition(evt)
    initialX = mousePosition.x
    initialY = mousePosition.y
    tCoords = getTranslateCoordinates(activeTarget)
    initialTX = tCoords.tx
    initialTY = tCoords.ty
    printState()    
    return

touchStarted = (evt) ->
    log "touchStarted"
    target = evt.target
    mode = "touch"
    activeTarget = target
    initialX = evt.clientX
    initialY = evt.clientY
    
    printState()
    return

elementClicked = (evt) ->
    log "elementClicked"
    evt.preventDefault()
    groupNode = getGroupNode(evt.target)
    id = getDataID(groupNode)
    dataEdit.editData(data[id])
    resetState()
    return

mouseUpped = (evt) ->
    log "mouseUpped"
    evt.preventDefault()
    printState()
    saveTransform()
    resetState()
    return

touchEnded = (evt) ->
    log "touchEnded"
    evt.preventDefault()
    printState()
    saveTransform()
    resetState()
    return

mouseMoved = (evt) ->
    log "mouseMoved"
    evt.preventDefault()
    # target = evt.target
    if mode == "mouse"
        isInMove = true
        dx = evt.offsetX - initialX + initialTX
        dy = evt.offsetY - initialY + initialTY
        transform = "translate("+dx+" "+dy+")"
        activeTarget.setAttributeNS(null, "transform", transform)
        
    printState()
    return

touchMoved = (evt) ->
    log "touchMoved"
    evt.preventDefault()
    if mode == "touch"
        isInMove = true
    
    # TODO create transform
    printState()
    return

mouseLeft = (evt) ->
    log "mouseLeft"
    evt.preventDefault()
    resetTransform()
    resetState()    
    return

touchCancelled = (evt) ->
    log "touchCancelled"
    evt.preventDefault()
    resetTransform()
    resetState()
    return


#endregion

############################################################
datadisplaymodule.displayData = ->
    log "datadisplaymodule.displayData"
    createDataPoint(d, i) for d,i in data
    return

    
module.exports = datadisplaymodule