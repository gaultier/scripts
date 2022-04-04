(require '[clojure.core.async :as async])

(defn exec [working-dir cmds]
  (.. (new ProcessBuilder cmds) (directory (clojure.java.io/file working-dir)) (start) (waitFor)))

(->> "/Users/pgaultier/projects/ppro-1648791067/" 
  (clojure.java.io/file)
  (file-seq)
  (filter #(.isDirectory %))
  (filter #(= (.getName %) ".git"))
  (map #(.getAbsolutePath (.getParentFile %)))
  ; (map #(println % (str "'(cd " % " && git pull)'"))))
  (map #(async/go [% (exec % ["git" "pull"])]))
  (map #(async/<!! %)))
  ; (print))


