(local {: startswith
        : tbl_contains
        : tbl_extend
        : tbl_deep_extend
        : tbl_filter
        : tbl_flatten
        : tbl_map
        : ui
        : validate
        :api {: nvim_buf_clear_namespace
              : nvim_buf_get_extmarks
              : nvim_buf_get_name
              : nvim_buf_get_option
              : nvim_buf_line_count
              : nvim_buf_set_extmark
              : nvim_create_augroup
              : nvim_create_autocmd
              : nvim_create_namespace
              : nvim_exec_autocmds
              : nvim_get_current_buf
              : nvim_echo
              : nvim_set_hl
              : nvim_win_get_cursor}
        :fn {: exists
             : delete
             : filereadable
             : flatten
             : fnamemodify
             : getcwd
             : mkdir
             : readdir
             : readfile
             : stdpath
             : substitute
             : writefile}
        :keymap {:set kset}} vim)

(local namespace (nvim_create_namespace :VirtNotes))
(local note-highlight :VirtNote)

(var default-mappings
     {:add {:keys :<prefix>a :opts {:desc "Add note"}}
      :edit {:keys :<prefix>e :opts {:desc "Edit note"}}
      :remove {:keys :<prefix>dd :opts {:desc "Delete note"}}
      :remove_on_line {:keys :<prefix>dl
                       :opts {:desc "Delete all notes on line"}}
      :remove-in-file {:keys :<prefix>da
                       :opts {:desc "Delete all notes in file"}}
      :copy {:keys :<prefix>c :opts {:desc "Copy note"}}
      ; move is deprecated but still does the same as cut
      :cut {:keys :<prefix>x :opts {:desc "Cut note"}}
      :paste {:keys :<prefix>p :opts {:desc "Paste note"}}})

(var notes-path (.. (stdpath :data) :/virt_notes))
(var remove-schemes [:oil])

(var ?saved-note nil)
(var delete-note-on-paste? false)

(local actions [])

(nvim_set_hl 0 note-highlight {:default true :link :WildMenu})

(lambda index-of [table value]
  (accumulate [index nil k v (pairs table) &until index]
    (if (= v value) k)))

(lambda clear-scheme [path]
  (accumulate [new-path path _ scheme (ipairs remove-schemes)]
    (string.gsub new-path (.. "^" scheme "://") "")))

(lambda get-absolute-path [?bufnr]
  (clear-scheme (nvim_buf_get_name (or ?bufnr 0))))

(lambda clean-path [path]
  (string.gsub path "/" "_"))

(lambda file->notes-file [file]
  (.. notes-path "/" (clean-path file) :.txt))

(lambda get-line []
  (let [[line] (nvim_win_get_cursor 0)]
    (- line 1)))

(lambda remove-scheme [notes-file]
  (substitute notes-file "^\\(\\w\\+:__\\)\\?" "" ""))

(lambda notes->virt-text [notes]
  (let [virt-text (-> (icollect [_ note (ipairs notes)]
                        [[note note-highlight] [" "]])
                      (flatten 1))]
    (table.remove virt-text)
    virt-text))

(lambda extmarks->notes [extmarks]
  (accumulate [notes {} _ [_ line _ {:virt_text virt-text}] (ipairs extmarks)]
    (let [existing (or (. notes line) [])
          virt-note-text (->> virt-text
                              (tbl_filter #(. $1 2))
                              (tbl_map #(. $1 1)))]
      (tset notes line (tbl_flatten [existing virt-note-text]))
      notes)))

(lambda get-all-notes [bufnr]
  "Get all notes from extmarks"
  (let [extmarks (nvim_buf_get_extmarks bufnr namespace 0 -1 {:details true})]
    (extmarks->notes extmarks)))

(lambda get-notes [bufnr line]
  "Get notes for line"
  (let [extmarks (nvim_buf_get_extmarks bufnr namespace [line 0] [line -1]
                                        {:details true})
        line-notes (extmarks->notes extmarks)]
    (or (. line-notes line) [])))

(lambda set-all-notes [bufnr all-notes ?disable-event]
  "Set all notes for buffer"
  (nvim_buf_clear_namespace bufnr namespace 0 -1)
  (let [max-line (nvim_buf_line_count bufnr)]
    (each [line notes (pairs all-notes)]
      (let [real-line (if (>= line max-line) (- max-line 1) line)]
        (nvim_buf_set_extmark bufnr namespace real-line 0
                              {:virt_text (notes->virt-text notes)}))))
  (when (not ?disable-event)
    (nvim_exec_autocmds :User
                        {:pattern :VirtualNotesUpdated :data {:buf bufnr}})))

(lambda set-notes [bufnr line notes ?disable-event]
  "Set notes for line"
  (nvim_buf_clear_namespace bufnr namespace line (+ line 1))
  (when (> (length notes) 0)
    (nvim_buf_set_extmark bufnr namespace line 0
                          {:virt_text (notes->virt-text notes)}))
  (when (not ?disable-event)
    (nvim_exec_autocmds :User
                        {:pattern :VirtualNotesUpdated :data {:buf bufnr}})))

(lambda add-note [bufnr line note]
  (let [existing (get-notes bufnr line)
        note-exists? (tbl_contains existing note)]
    (when (not note-exists?)
      (table.insert existing note)
      (set-notes bufnr line existing))))

(lambda remove-note [bufnr line note]
  (let [existing (get-notes bufnr line)
        ?note-index (index-of existing note)]
    (when ?note-index
      (table.remove existing ?note-index)
      (set-notes bufnr line existing))))

(lambda edit-note [bufnr line old-note new-note]
  (let [existing (get-notes bufnr line)
        ?note-index (index-of existing old-note)]
    (when ?note-index
      (tset existing ?note-index new-note)
      (set-notes bufnr line existing))))

(lambda note->line [line-nr note]
  (.. line-nr " " note))

(lambda line->note [line]
  (string.match line "^(%d+) (.*)$"))

(lambda persist-notes [bufnr file]
  "Presist notes to file or delete it. File must be absolute path."
  (let [notes-file (file->notes-file file)
        all-notes (get-all-notes bufnr)
        lines (tbl_flatten (icollect [line notes (pairs all-notes)]
                             (icollect [_ note (ipairs notes)]
                               (note->line line note))))]
    (if (= 0 (length lines))
        (delete notes-file)
        (do
          (table.insert lines 1 file)
          (writefile lines notes-file)))))

(lambda parse-notes-file [lines]
  "Parse notes file content and return file name and notes"
  "First line of notes file has to be file name"
  (let [file (. lines 1)]
    (table.remove lines 1)
    [file
     (accumulate [notes {} _ line (ipairs lines)]
       (let [(line-nr-str note) (line->note line)
             linenr (tonumber line-nr-str)
             existing (or (. notes linenr) [])]
         (when (and linenr note)
           (table.insert existing note)
           (tset notes linenr existing))
         notes))]))

(lambda get-notes-from-file [notes-file]
  "Return [file notes]"
  (match (pcall readfile notes-file)
    (true [l &as lines]) (parse-notes-file lines)
    _ [nil []]))

(fn get-notes-in-files [files]
  "Return {:file {:line [notes]}}"
  (collect [_ notes-file (ipairs files)]
    (let [notes-file (.. notes-path "/" notes-file)
          [file all-notes] (get-notes-from-file notes-file)]
      (values file all-notes))))

(lambda load-notes [bufnr file]
  "File must be absolute path"
  (let [notes-file (file->notes-file file)
        [_ all-notes] (get-notes-from-file notes-file)]
    (set-all-notes bufnr all-notes true)))

(lambda on-choice [callback ?choice]
  (if ?choice (callback ?choice)))

(lambda select-note-on-line [prompt bufnr line callback]
  (match (get-notes bufnr line)
    [x y &as notes] (ui.select notes {: prompt} (partial on-choice callback))
    [entry] (callback entry)
    _ nil))

(fn get-project-notes-files [cwd]
  (let [clean-cwd (clean-path cwd)
        (has-files? notes-files) (pcall readdir notes-path)]
    (if has-files?
        (tbl_filter #(startswith $1 clean-cwd) notes-files)
        [])))

(lambda get-notes-in-cwd []
  "Return {:file {:line [notes]}}"
  (let [cwd (getcwd)
        notes-files (get-project-notes-files cwd)]
    (get-notes-in-files notes-files)))

(lambda save-note [delete-on-paste? bufnr line note]
  (set ?saved-note {: bufnr : line : note})
  (set delete-note-on-paste? delete-on-paste?))

(lambda on-buf-read [{:buf bufnr}]
  (let [file (get-absolute-path bufnr)]
    (when (not= "" file)
      (load-notes bufnr file))))

(lambda on-buf-write [{:buf bufnr}]
  (let [file (get-absolute-path bufnr)]
    (when (= 1 (filereadable file))
      (persist-notes bufnr file))))

(lambda on-virt-notes-updated [{:buf bufnr}]
  (let [file (get-absolute-path bufnr)
        modified? (nvim_buf_get_option bufnr :modified)]
    (when (and (not modified?) (not= "" file))
      (persist-notes bufnr file))))

(fn actions.add []
  (let [file (get-absolute-path)
        bufnr (nvim_get_current_buf)
        line (get-line)]
    (ui.input {:prompt "Add note:"}
              (partial on-choice #(add-note bufnr line $1)))))

(fn actions.edit []
  (let [file (get-absolute-path)
        bufnr (nvim_get_current_buf)
        line (get-line)
        on-select (fn [note]
                    (ui.input {:prompt "Edit note: " :default note}
                              (partial on-choice
                                       #(edit-note bufnr line note $1))))]
    (select-note-on-line "Edit note" bufnr line on-select)))

(fn actions.remove []
  (let [file (get-absolute-path)
        bufnr (nvim_get_current_buf)
        line (get-line)]
    (select-note-on-line "Remove note" bufnr line
                         (partial remove-note bufnr line))))

(fn actions.remove_on_line []
  (let [file (get-absolute-path)
        bufnr (nvim_get_current_buf)
        line (get-line)]
    (set-notes bufnr line [])))

(fn actions.remove_in_file []
  (let [file (get-absolute-path)
        bufnr (nvim_get_current_buf)]
    (set-all-notes bufnr [])))

(lambda actions.save-note [?prompt ?success-msg ?delete-on-paste?]
  (let [prompt (or ?prompt "Save note")
        success-msg (or ?success-msg "Note saved")
        delete-on-paste? (or ?delete-on-paste? false)
        bufnr (nvim_get_current_buf)
        line (get-line)]
    (select-note-on-line prompt bufnr line
                         #(do
                            (save-note delete-on-paste? bufnr line $1)
                            (nvim_echo [[success-msg] [": "] [$1]] false {})))))

(fn actions.copy []
  (actions.save-note "Copy note" "Note copied" false))

(fn actions.move []
  (vim.deprecate "actions.move()" "actions.cut()" :2024 :virt-notes.nvim true)
  (actions.save-note "Move note" "Moving note" true))

(fn actions.cut []
  (actions.save-note "Cut note" "Note cut" true))

(fn actions.paste []
  (if ?saved-note
      (let [file (get-absolute-path)
            bufnr (nvim_get_current_buf)
            line (get-line)
            note-text ?saved-note.note]
        (when delete-note-on-paste?
          (remove-note ?saved-note.bufnr ?saved-note.line ?saved-note.note))
        (add-note bufnr line note-text)
        (save-note delete-note-on-paste? bufnr line note-text))
      (nvim_echo [["No note selected" :ErrorMsg]] false {})))

(lambda replace-prefix [keys prefix]
  (string.gsub keys "<([^>]+)>" (fn [word]
                                  (if (= (string.lower word) :prefix)
                                      prefix))))

(lambda map-keys [prefix mappings]
  "Map keys while replacing <Prefix> with prefix"
  (let [set-mappings (tbl_map #(if (= $1 false) nil $1) mappings)]
    (each [action {: keys : opts} (pairs set-mappings)]
      (let [real-keys (replace-prefix keys prefix)
            callback (. actions action)]
        (when callback
          (kset :n real-keys callback opts))))))

(lambda validate-config [config]
  (let [user-mappings (or (?. config.mappings :actions) {})
        map-rules (collect [action map-opts (pairs user-mappings)]
                    (values (.. :mappings.actions. action)
                            [map-opts [:table :string :boolean]]))
        rules {:notes_path [config.notes_path [:string :nil]]
               :hl_group [config.hl_group [:string :nil]]
               :remove_schemes [config.remove_schemes [:table :nil]]
               :mappings [config.mappings [:table :boolean :nil]]
               :mappings.prefix [(?. config.mappings :prefix) [:string :nil]]
               :mappings.actions [(?. config.mappings :actions) [:table :nil]]}]
    (validate (tbl_extend :error rules map-rules))))

(lambda apply-config [config]
  (when config.notes_path
    (set notes-path config.notes_path))
  (when config.hl_group
    (nvim_set_hl 0 note-highlight {:link config.hl_group}))
  (when config.remove_schemes
    (set remove-schemes config.remove_schemes))
  (when (not= config.mappings false)
    (let [map-cfg (or config.mappings {})
          prefix (or map-cfg.prefix :<Leader>v)
          key-actions (->> (or map-cfg.actions {})
                           (tbl_map #(if (= (type $1) :string) {:keys $1} $1)))]
      (map-keys prefix (tbl_deep_extend :force default-mappings key-actions)))))

(lambda fix-config [config]
  (when (?. config :mappings :actions :move)
    (tset config.mappings.actions :cut config.mappings.actions.move)
    (tset config.mappings.actions :move nil))
  config)

(fn setup [?config]
  (let [config (fix-config (or ?config {}))]
    (validate-config config)
    (apply-config config))
  (mkdir notes-path :p)
  (when (= 1 (exists "g:loaded_telescope"))
    (let [{: load_extension} (require :telescope)]
      (load_extension :virt_notes)))
  (let [group (nvim_create_augroup :VirtNotes {:clear true})]
    (nvim_create_autocmd :BufRead {: group :callback on-buf-read})
    (nvim_create_autocmd :BufWrite {: group :callback on-buf-write})
    (nvim_create_autocmd :User
                         {: group
                          :pattern :VirtualNotesUpdated
                          :callback on-virt-notes-updated})))

{: setup
 :get_notes_in_cwd get-notes-in-cwd
 :get_notes_in_files get-notes-in-files
 : actions}
