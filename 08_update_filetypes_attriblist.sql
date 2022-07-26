UPDATE public.filetypes SET filetype='HTML (original)', sortorder=6 WHERE pk='html';
UPDATE public.filetypes SET filetype='HTML (no images)', sortorder=7 WHERE pk='html.noimages';
UPDATE public.filetypes SET filetype='HTML', sortorder=5 WHERE pk='html.images';
UPDATE public.attriblist SET caption='Original Publication' WHERE pk=260;