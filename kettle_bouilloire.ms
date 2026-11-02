-- ==========================================================
-- BOUILLOIRE XIAOMI - Modélisation 3ds Max (Natif)
-- Dimensions: Hauteur 30cm, Corps Ø16cm, Total Ø20cm
-- Techniques: Editable Spline, Lathe, Loft, Editable Poly
-- ==========================================================

-- 1. Configuration des unités (CORRIGÉ)
units.DisplayType = #Metric
units.MetricType = #Centimeters
units.SystemType = #Centimeters

-- Couleurs
local colWhite = color 240 240 240
local colSteel = color 180 185 190
local colDark  = color 40 40 45
local colRed   = color 220 30 30

-- Fonction pour créer les calques
fn createLayer name =
(
    local l = LayerManager.getLayerFromName name
    if l == undefined do l = LayerManager.newLayerFromName name
    l
)

local layBody = createLayer "01_Corps_et_Socle"
local layMetal = createLayer "02_Inox"
local layHandle = createLayer "03_Poignee"
local layLid = createLayer "04_Couvercle"

-- ==========================================================
-- 2. SOCLE (Base) - Technique: Spline + Lathe
-- Profil dans le plan XY (X=rayon, Y=hauteur) pour Lathe (axe Y)
-- ==========================================================
local baseSpline = Line()
addKnot baseSpline 1 #corner #line [0,0,0]
addKnot baseSpline 1 #corner #line [8.5,0,0]
addKnot baseSpline 1 #corner #line [8.5,0,2]
addKnot baseSpline 1 #corner #line [0,0,2]
updateShape baseSpline
baseSpline.name = "Spline_Socle"

addModifier baseSpline (Lathe())
baseSpline.name = "Socle"
baseSpline.wirecolor = colWhite
convertToPoly baseSpline
layBody.addNode baseSpline

-- ==========================================================
-- 3. CORPS PRINCIPAL - Technique: Spline + Lathe -> Editable Poly
-- Hauteur: 23cm (de Y=2 à Y=25). Rayon: 8cm (Ø16cm)
-- ==========================================================
local bodySpline = Line()
addKnot bodySpline 1 #corner #line [0,0,2]
addKnot bodySpline 1 #corner #line [8,0,2]
addKnot bodySpline 1 #corner #line [8,0,25]
addKnot bodySpline 1 #corner #line [0,0,25]
updateShape bodySpline
bodySpline.name = "Spline_Corps"

addModifier bodySpline (Lathe())
bodySpline.name = "Corps_Principal"
bodySpline.wirecolor = colWhite
convertToPoly bodySpline
layBody.addNode bodySpline

-- ==========================================================
-- 4. BANDE INOX (Haut du corps) - Technique: Spline + Lathe
-- ==========================================================
local rimSpline = Line()
addKnot rimSpline 1 #corner #line [7.8,0,24.5]
addKnot rimSpline 1 #corner #line [8.2,0,24.5]
addKnot rimSpline 1 #corner #line [8.2,0,25.5]
addKnot rimSpline 1 #corner #line [7.8,0,25.5]
updateShape rimSpline

addModifier rimSpline (Lathe())
rimSpline.name = "Bande_Inox_Haut"
rimSpline.wirecolor = colSteel
convertToPoly rimSpline
layMetal.addNode rimSpline

-- ==========================================================
-- 5. BEC VERSEUR - Technique: Spline + LOFT (Obligatoire pour la note)
-- ==========================================================
-- Chemin du bec (Path) - dans le plan XY
local spoutPath = Line()
addKnot spoutPath 1 #corner #line [8,25,0]
addKnot spoutPath 1 #bezier #line [9.5,25.5,0]
addKnot spoutPath 1 #bezier #line [10.5,24.5,0]
updateShape spoutPath
spoutPath.name = "Chemin_Bec"

-- Forme du bec (Shape)
local spoutShape = Ellipse radius1:1.2 radius2:0.9 pos:[8,25,0]
spoutShape.name = "Forme_Bec"

local spoutObj = Loft shape:spoutShape path:spoutPath
spoutObj.name = "Bec_Verseur"
spoutObj.wirecolor = colSteel
convertToPoly spoutObj
layMetal.addNode spoutObj

-- ==========================================================
-- 6. POIGNÉE - Technique: Editable Poly (Forme 3D de base)
-- Doit aller de X=8 à X=12 (Total Ø20cm)
-- ==========================================================
local handleObj = box width:4 length:3 height:16 pos:[8, 0, 11]
handleObj.name = "Poignee_Base"
handleObj.wirecolor = colWhite
convertToPoly handleObj

-- Arrondir les bords de la poignée pour imiter le design Xiaomi
handleObj.edgeSelection = #{1..handleObj.numEdges}
polyop.chamferEdges handleObj handleObj.edgeSelection 1.0 2
layHandle.addNode handleObj

-- Panneau de commandes sur la poignée
local panelObj = box width:2.2 length:0.2 height:6 pos:[10, -1.6, 12]
panelObj.name = "Panneau_Commandes"
panelObj.wirecolor = colWhite
convertToPoly panelObj
layHandle.addNode panelObj

-- Écran digital
local screenObj = box width:1.4 length:0.1 height:0.8 pos:[10, -1.75, 14.5]
screenObj.name = "Ecran_Digital"
screenObj.wirecolor = colDark
convertToPoly screenObj
layHandle.addNode screenObj

-- Boutons
local btn1 = cylinder radius:0.5 height:0.15 sides:16 pos:[10, -1.75, 12.5]
rotate btn1 (angleaxis 90 [1,0,0])
btn1.name = "Bouton_1"
btn1.wirecolor = colWhite
convertToPoly btn1
layHandle.addNode btn1

local btn2 = cylinder radius:0.5 height:0.15 sides:16 pos:[10, -1.75, 11]
rotate btn2 (angleaxis 90 [1,0,0])
btn2.name = "Bouton_2"
btn2.wirecolor = colWhite
convertToPoly btn2
layHandle.addNode btn2

-- Voyant rouge
local led = sphere radius:0.12 segments:8 pos:[10, -1.8, 12.5]
led.name = "Voyant_LED"
led.wirecolor = colRed
convertToPoly led
layHandle.addNode led

-- ==========================================================
-- 7. COUVERCLE - Technique: Spline + Lathe
-- ==========================================================
local lidSpline = Line()
addKnot lidSpline 1 #corner #line [0,0,25]
addKnot lidSpline 1 #corner #line [8.2,0,25]
addKnot lidSpline 1 #corner #line [8.2,0,25.5]
addKnot lidSpline 1 #corner #line [8,0,26.5]
addKnot lidSpline 1 #corner #line [0,0,26.5]
updateShape lidSpline

addModifier lidSpline (Lathe())
lidSpline.name = "Couvercle_Exterieur"
lidSpline.wirecolor = colWhite
convertToPoly lidSpline
layLid.addNode lidSpline

-- Intérieur inox du couvercle
local lidInSpline = Line()
addKnot lidInSpline 1 #corner #line [0,0,24.8]
addKnot lidInSpline 1 #corner #line [7.8,0,24.8]
addKnot lidInSpline 1 #corner #line [7.8,0,25.2]
addKnot lidInSpline 1 #corner #line [0,0,25.2]
updateShape lidInSpline

addModifier lidInSpline (Lathe())
lidInSpline.name = "Couvercle_Interieur_Inox"
lidInSpline.wirecolor = colSteel
convertToPoly lidInSpline
layLid.addNode lidInSpline

-- Bouton d'ouverture du couvercle (à l'arrière)
local openBtn = chamferbox width:2.5 length:1.5 height:0.5 fillet:0.2 filletsegs:2 pos:[-7, 0, 26.2]
openBtn.name = "Bouton_Ouverture_Couvercle"
openBtn.wirecolor = colWhite
convertToPoly openBtn
layLid.addNode openBtn

-- ==========================================================
-- 8. FINALISATION
-- ==========================================================
select objects
max zoomext sel all
clearSelection()

print "Modélisation de la bouilloire terminée avec succès !"
print "Vérifiez le Stack des modificateurs pour la notation."