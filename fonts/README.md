Add DDC Hardware font files here

Expected filename:
- DDCHardware-Regular.woff2 (Regular, weight 400)

How to use:
- Place the WOFF2 file above in this folder. The site loads it via
  @font-face in index.html with:
  url("fonts/DDCHardware-Regular.woff2") format("woff2").

Notes:
- If the font is installed on your system as "DDC Hardware" or
  "DDC Hardware Regular", the site will use it via local() even
  without this file. Shipping the WOFF2 ensures it works for everyone.

