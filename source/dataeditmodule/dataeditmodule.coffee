dataeditmodule = {name: "dataeditmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["dataeditmodule"]?  then console.log "[dataeditmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
dataeditmodule.initialize = () ->
    log "dataeditmodule.initialize"
    dataedit.addEventListener("click", backgroundClicked)
    return
    

backgroundClicked = ->
    log "backgroundClicked"
    dataedit.classList.remove("present")
    return


dataeditmodule.editData = (data) ->
    log "dataeditmodule.editData"
    dataedit.classList.add("present")
    
    meta = data.meta
    label = data.label
    content = data.content

    dataMetaEdit.value = JSON.stringify(meta, null, 4)
    dataLabelEdit.value = label
    dataContentEdit.value = content
    return

module.exports = dataeditmodule