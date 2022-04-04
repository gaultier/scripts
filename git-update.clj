(require '[clojure.java.io :as io])
(require '[clojure.core.async :as async])

(defn exec [working-dir cmds]
  (.. (new ProcessBuilder cmds) (directory (io/file working-dir)) (start)))

(defn git-update [channel root]
  (->> root 
    (io/file)
    (file-seq)
    (filter #(.isDirectory %))
    (filter #(= (.getName %) ".git"))
    (map #(.getAbsolutePath (.getParentFile %)))
    (pmap (fn [path] 
            (println "⏳ Fetching" path)
            (let [p (exec path ["git" "pull"])]
              (if (not= 0 (.waitFor p))
                (async/put! channel (str "❌ " path (slurp (.getErrorStream p))))
                (async/put! channel (str "✓ " path))))))
    (doall))
  (async/close! channel))

(def channel (async/chan 100000))
(async/go (git-update channel "/Users/pgaultier/projects/ppro-1648791067/"))

(time (loop [x (async/<!! channel)]
        (when x
          (do 
            (println x)
            (recur (async/<!! channel))))))
