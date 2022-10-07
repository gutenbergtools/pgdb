UPDATE public.filetypes SET filetype='HTML5 (no images)', sortorder=7 WHERE pk='html.noimages';
UPDATE public.filetypes SET filetype='HTML5', sortorder=5 WHERE pk='html.images';
UPDATE public.filetypes SET filetype='EPUB3 (E-readers incl. Send-to-Kindle)', sortorder=8 WHERE pk='epub3.images';
UPDATE public.filetypes SET filetype='EPUB (e-readers)', sortorder=9 WHERE pk='epub.images';
UPDATE public.filetypes SET filetype='EPUB (no images)', sortorder=11 WHERE pk='epub.noimages';
UPDATE public.filetypes SET filetype='MOBI (sideload to Kindle)', sortorder=15 WHERE pk='kf8.images';
