UPDATE public.filetypes SET filetype='HTML5', sortorder=5 WHERE pk='html.images';
UPDATE public.filetypes SET filetype='HTML (as submitted)', sortorder=7 WHERE pk='html';
UPDATE public.filetypes SET filetype='HTML5 (no images)', sortorder=8 WHERE pk='html.noimages';
UPDATE public.filetypes SET filetype='EPUB3 (E-readers incl. Send-to-Kindle)', sortorder=8 WHERE pk='epub3.images';
UPDATE public.filetypes SET filetype='EPUB (older E-readers)', sortorder=9 WHERE pk='epub.images';
UPDATE public.filetypes SET filetype='EPUB (no images)', sortorder=11 WHERE pk='epub.noimages';
UPDATE public.filetypes SET filetype='Kindle', sortorder=15 WHERE pk='kf8.images';
UPDATE public.filetypes SET filetype='older Kindles', sortorder=20 WHERE pk='kindle.images';
