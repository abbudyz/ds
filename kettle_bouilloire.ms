-- Bouilloire electrique (Xiaomi style) - modele complet, 3ds Max 2025
-- Composants : corps, bande/doublure inox, bec verseur, poignee, couvercle, socle, commandes
-- Tous les objets sont convertis en Editable Poly et ranges par calques (Layers).
-- Run: Scripting > Run Script...   puis File > Save As .max
-- Unites : cm

(
    -- ===== Parametres =====
    local lidAngle = 0.0      -- 0 = couvercle ferme ; mettre 70 pour l'ouvrir
    local seg = 48            -- segments des revolutions

    local whiteC = color 245 245 245
    local steelC = color 190 198 205
    local grayC  = color 165 165 170
    local darkC  = color 35 35 40
    local redC   = color 230 30 30
    local btnC   = color 225 225 228

    -- ===== Outils =====
    fn getLayer nm =
    (
        local l = LayerManager.getLayerFromName nm
        if l == undefined do l = LayerManager.newLayerFromName nm
        l
    )

    fn fin o nm col lay =
    (
        o.name = nm
        o.wirecolor = col
        o.material = StandardMaterial diffuse:col name:(nm + "_mat")
        o.backfaceCull = false
        (getLayer lay).addNode o
        o
    )

    -- surface de revolution autour de Z : profil = points [r, z] ordonnes dans le sens anti-horaire
    fn revolveMesh pts closed nseg =
    (
        local verts = #()
        local ids = #()
        for i = 1 to pts.count do
        (
            local arr = #()
            if pts[i].x < 0.0001 then
            (
                append verts [0, 0, pts[i].y]
                local id = verts.count
                for k = 1 to nseg do append arr id
            )
            else
            (
                for k = 1 to nseg do
                (
                    local ang = 360.0 * (k - 1) / nseg
                    append verts [pts[i].x * (cos ang), pts[i].x * (sin ang), pts[i].y]
                    append arr verts.count
                )
            )
            append ids arr
        )
        local faces = #()
        local n = pts.count
        local lastEdge = n - 1
        if closed do lastEdge = n
        for i = 1 to lastEdge do
        (
            local j = i + 1
            if i == n do j = 1
            for k = 1 to nseg do
            (
                local k2 = k + 1
                if k == nseg do k2 = 1
                local a = ids[i][k]
                local b = ids[j][k]
                local c = ids[j][k2]
                local d = ids[i][k2]
                if (a != c and a != b and b != c) do append faces [a, c, b]
                if (a != c and a != d and d != c) do append faces [a, d, c]
            )
        )
        local m = mesh vertices:verts faces:faces
        addModifier m (Smooth autoSmooth:true threshold:35)
        convertToPoly m
        m
    )

    -- spline de Catmull-Rom (points 3D)
    fn catmull p0 p1 p2 p3 t =
    (
        0.5 * ((2.0 * p1) + ((p2 - p0) * t) + ((2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t) + ((3.0 * p1 - p0 - 3.0 * p2 + p3) * t * t * t))
    )

    -- balayage d'un profil rectangulaire arrondi le long d'un chemin dans le plan XZ
    fn sweepMesh cps hw hh nring ss =
    (
        local pts = #()
        for i = 1 to (cps.count - 1) do
        (
            local p0 = cps[i]
            if i > 1 do p0 = cps[i - 1]
            local p1 = cps[i]
            local p2 = cps[i + 1]
            local p3 = cps[cps.count]
            if (i + 2) <= cps.count do p3 = cps[i + 2]
            for s = 0 to (ss - 1) do append pts (catmull p0 p1 p2 p3 (s / (ss as float)))
        )
        append pts cps[cps.count]

        local verts = #()
        local faces = #()
        for i = 1 to pts.count do
        (
            local prv = pts[(amax #(i - 1, 1))]
            local nxt = pts[(amin #(i + 1, pts.count))]
            local T = normalize (nxt - prv)
            local N = [-T.z, 0, T.x]
            local B = [0, 1, 0]
            for j = 1 to nring do
            (
                local ang = 360.0 * (j - 1) / nring
                local c = cos ang
                local s = sin ang
                local ex = (abs c) ^ 0.5
                if c < 0 do ex = -ex
                local ey = (abs s) ^ 0.5
                if s < 0 do ey = -ey
                append verts (pts[i] + B * (hw * ex) + N * (hh * ey))
            )
        )
        local nSt = pts.count
        for i = 1 to (nSt - 1) do
        (
            for j = 1 to nring do
            (
                local j2 = j + 1
                if j == nring do j2 = 1
                local v1 = (i - 1) * nring + j
                local v2 = (i - 1) * nring + j2
                local v3 = i * nring + j2
                local v4 = i * nring + j
                append faces [v1, v2, v3]
                append faces [v1, v3, v4]
            )
        )
        -- bouchons aux deux extremites
        append verts pts[1]
        local cStart = verts.count
        append verts pts[nSt]
        local cEnd = verts.count
        for j = 1 to nring do
        (
            local j2 = j + 1
            if j == nring do j2 = 1
            append faces [cStart, j2, j]
            append faces [cEnd, (nSt - 1) * nring + j, (nSt - 1) * nring + j2]
        )
        local m = mesh vertices:verts faces:faces
        addModifier m (Smooth autoSmooth:true threshold:35)
        convertToPoly m
        m
    )

    -- ===== 1. CORPS (blanc) =====
    local bodyPts = #([0, 2.0], [8.1, 2.0], [8.3, 18.6], [7.95, 18.6], [7.8, 3.0], [0, 3.0])
    local body = revolveMesh bodyPts false seg
    fin body "Corps_Principal" whiteC "01_Corps"

    -- ===== 2. INOX : bande haute + doublure interieure =====
    local bandPts = #([8.35, 18.6], [8.35, 21.5], [7.9, 21.5], [7.9, 18.6])
    local band = revolveMesh bandPts true seg
    fin band "Bande_Inox" steelC "02_Inox"

    local linerPts = #([0, 3.1], [7.9, 3.1], [7.9, 21.5], [7.6, 21.5], [7.6, 3.4], [0, 3.4])
    local liner = revolveMesh linerPts false seg
    fin liner "Doublure_Inox" steelC "02_Inox"

    -- ===== 3. BEC VERSEUR =====
    local spout = Cone radius1:2.8 radius2:0.9 height:3.8 sides:24 heightsegs:1 capsegs:1 pos:[7.9, 0, 20.1]
    spout.rotation = (eulerAngles 0 90 0)
    spout.scale = [0.5, 1, 1]
    convertToPoly spout
    fin spout "Bec_Verseur" steelC "03_Bec"

    -- ===== 4. POIGNEE (profil arrondi balaye le long d'un chemin) =====
    local cps = #([-7.4, 0, 20.4], [-9.5, 0, 20.4], [-12.2, 0, 19.6], [-14.2, 0, 17.4], [-14.2, 0, 13.5], [-14.2, 0, 10.2], [-12.4, 0, 7.7], [-9.8, 0, 6.9], [-7.4, 0, 6.9])
    local handle = sweepMesh cps 2.4 1.45 16 8
    fin handle "Poignee" whiteC "04_Poignee"

    -- ===== 5. SOCLE =====
    local basePts = #([0, 0], [8.7, 0], [8.7, 1.6], [0, 1.6])
    local baseM = revolveMesh basePts false seg
    fin baseM "Socle" whiteC "06_Socle"

    local groovePts = #([0, 1.6], [8.5, 1.6], [8.5, 2.0], [0, 2.0])
    local groove = revolveMesh groovePts false seg
    fin groove "Socle_Rainure" grayC "06_Socle"

    -- ===== 6. COUVERCLE (articule autour d'une charniere) =====
    local lidPts = #([0, 21.5], [8.6, 21.5], [8.6, 22.1], [8.3, 22.5], [0, 22.5])
    local lid = revolveMesh lidPts false seg
    fin lid "Couvercle" whiteC "05_Couvercle"

    local lidInPts = #([0, 21.3], [8.1, 21.3], [8.1, 21.5], [0, 21.5])
    local lidIn = revolveMesh lidInPts false seg
    fin lidIn "Couvercle_Inox" steelC "05_Couvercle"

    local btnTop = ChamferBox width:3.0 length:2.6 height:0.6 fillet:0.25 filletsegs:2 pos:[-11.6, 0, 21.7]
    convertToPoly btnTop
    fin btnTop "Bouton_Ouverture" btnC "07_Commandes"

    -- charniere
    local hinge = Dummy boxsize:[1, 1, 1] pos:[-8.0, 0, 22.0]
    hinge.name = "Charniere_Couvercle"
    lid.parent = hinge
    lidIn.parent = hinge

    -- ===== 7. COMMANDES sur la poignee (face -Y) =====
    local py = -2.4
    local panel = Box width:2.4 length:0.15 height:6.8 pos:[-14.2, py - 0.05, 10.4]
    convertToPoly panel
    fin panel "Panneau_Commandes" btnC "07_Commandes"

    local disp = Box width:1.6 length:0.1 height:1.0 pos:[-14.2, py - 0.15, 15.9]
    convertToPoly disp
    fin disp "Afficheur" darkC "07_Commandes"

    local b1 = Cylinder radius:0.7 height:0.1 sides:20 pos:[-14.2, py - 0.1, 13.7]
    b1.rotation = (eulerAngles 90 0 0)
    convertToPoly b1
    fin b1 "Bouton_1" grayC "07_Commandes"

    local b2 = Cylinder radius:0.7 height:0.1 sides:20 pos:[-14.2, py - 0.1, 11.8]
    b2.rotation = (eulerAngles 90 0 0)
    convertToPoly b2
    fin b2 "Bouton_2" grayC "07_Commandes"

    local led = Sphere radius:0.12 segments:6 pos:[-14.2, py - 0.25, 13.7]
    convertToPoly led
    fin led "Voyant_Rouge" redC "07_Commandes"

    -- ===== Ouverture eventuelle du couvercle =====
    if lidAngle != 0 do rotate hinge (angleaxis (-lidAngle) [0, 1, 0])

    select objects
    max zoomext sel all
    clearSelection()
    format "Bouilloire creee (objets : %).\n" objects.count
)
