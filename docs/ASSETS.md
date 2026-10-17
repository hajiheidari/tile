# Assets and licenses

| Asset | Source | Status / license |
|---|---|---|
| Terrain, terrace/pool, trees, chalk, hand meshes and rig | Original procedural geometry in this repository | Continuous hand meshes and decorative geometry; hand anatomy/pose still needs art review |
| Glass appearance | Original `assets/shaders/marble.gdshader` | Interior twist sampling, screen-space refraction and stylized reflections; not physically exact ray-traced glass |
| Distant Isfahan architecture | Built-in OpenAI image generation | `assets/isfahan-landmark.png`, transparent 2D matte painting behind 3D foreground; no collision or gameplay state is derived from the image |
| Packed dirt surface texture | Built-in OpenAI image generation | `assets/packed-dirt.png`, original top-down albedo detail on the real terrain mesh |
| Persian geometric tile pattern | Original SVG | `assets/tiles.svg`; source for retained alternative mesh study |
| Rolling / impact sounds | Original synthesis in `audio.gd` | Temporary sound design; final glass/wall/sand differentiation and location ambience remain |
| App icon | Original SVG in `assets/icon.svg` | Prototype |
| Menu illustration | Generated with built-in OpenAI image generation for this project | `assets/isfahan-menu.png`, illustrative menu art only; never used to fake 3D gameplay |
| Noto Sans Arabic | Google Fonts `ofl/notosansarabic` | SIL OFL 1.1; `assets/fonts/OFL-Arabic.txt` |
| Noto Sans Devanagari | Google Fonts `ofl/notosansdevanagari` | SIL OFL 1.1; `assets/fonts/OFL-Devanagari.txt` |
| Godot engine and templates | Official Godot 4.5.1 distribution | MIT plus third-party notices; see https://godotengine.org/license/ |

No purchased assets, copied game IP, paid SDKs, advertisements or store purchases.

## Generated menu artwork prompt

Built-in image generation, original landscape illustration: highly polished cartoon 3D Naqsh-e Jahan square in Isfahan, recognizable turquoise dome, iwan and slim minarets, golden arcades, rounded trees, soft clouds, warm afternoon light; three colored glass marbles and a faint chalk square on a foreground dirt patch; turquoise/amber/cream palette; wide 16:9, no text, logo or hands. This image is a menu illustration, not an engine-rendered screenshot.

The previously approved concept images remain art direction references. Their appearance and hand pose are not claimed to have been reproduced at production quality in the prototype.

## v0.2 generated asset briefs (built-in mode)

- Landmark: transparent, panoramic 3:1 cartoon 3D-style cutout of the Shah Mosque and Naqsh-e Jahan arcades, iwan left of center, turquoise dome right of center, full minaret silhouettes, warm sun from upper left, finely patterned tiles; no sky, ground, gameplay objects or UI. Used only as distant scenery.
- Dirt: seamless square top-down albedo of well-packed warm ochre courtyard soil, understated hand-painted mottling and fine granules, even lighting; no holes, deep ruts, grass, objects or UI. Applied as texture detail; does not introduce hidden collision bumps.
