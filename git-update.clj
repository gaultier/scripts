(require '[clojure.java.io :as io])

(defn exec [working-dir cmds]
  (.. (new ProcessBuilder cmds) (directory (io/file working-dir)) (start)))

(defn git-update [root]
  (->> root 
    (io/file)
    (file-seq)
    (filter #(.isDirectory %))
    (filter #(= (.getName %) ".git"))
    (map #(.getAbsolutePath (.getParentFile %)))
    ; (map #(doto % prn))
    (pmap (fn [path] 
            (println path)
            (let [p (exec path ["git" "pull"])]
              (if (not= 0 (.waitFor p))
                (println "NOT OK" path (.getErrorStream p))
                (println "OK" path)))))))

(git-update "/Users/pgaultier/projects/ppro-1648791067")
