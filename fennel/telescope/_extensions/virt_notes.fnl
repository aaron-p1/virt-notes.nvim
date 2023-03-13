(local {:fn {: flatten : fnamemodify}} vim)

(local {: register_extension} (require :telescope))
(local {:new new-picker} (require :telescope.pickers))
(local {:new_table new-finder} (require :telescope.finders))
(local {:values {: generic_sorter : grep_previewer}}
       (require :telescope.config))

(local {: get_notes_in_cwd} (require :virt-notes))

(lambda notes->note-entries [notes]
  "Convert {:file {:line [notes]}} to [{: file : line : note}]"
  (let [nested (icollect [file file-notes (pairs notes)]
                 (icollect [line notes (pairs file-notes)]
                   (icollect [_ note (ipairs notes)]
                     {: file : line : note})))]
    (flatten nested)))

(lambda note-entry->telescope-entry [note-entry]
  (let [path (fnamemodify note-entry.file ":.")]
    {:value note-entry
     :display (.. path " | " note-entry.note)
     :ordinal (.. path " " note-entry.line " " note-entry.note)
     :path note-entry.file
     :lnum (+ 1 note-entry.line)}))

(lambda telescope-virt-notes [?opts]
  (let [opts (or ?opts {})
        notes (get_notes_in_cwd)
        results (notes->note-entries notes)
        finder (new-finder {: results :entry_maker note-entry->telescope-entry})
        picker (new-picker opts
                           {:results_title "Virtual Notes"
                            :prompt_title "Filter Virtual Notes"
                            : finder
                            :sorter (generic_sorter opts)
                            :previewer (grep_previewer opts)})]
    (picker:find)))

(register_extension {:exports {:virt_notes telescope-virt-notes}})
