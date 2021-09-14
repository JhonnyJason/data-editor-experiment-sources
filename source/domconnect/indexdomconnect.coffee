indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.dataedit = document.getElementById("dataedit")
    global.dataMetaEdit = document.getElementById("data-meta-edit")
    global.dataLabelEdit = document.getElementById("data-label-edit")
    global.dataContentEdit = document.getElementById("data-content-edit")
    global.datadisplay = document.getElementById("datadisplay")
    return
    
module.exports = indexdomconnect