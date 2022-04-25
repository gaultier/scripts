(require '[clojure.java.io :as io])
(require '[clojure.core.async :as async])
(require '[clojure.string :as string])

(defn exec [working-dir cmds]
  (.. (new ProcessBuilder cmds) (directory (io/file working-dir)) (start)))

(defn git-status [working-dir]
  (string/trim-newline (slurp (.getInputStream (exec working-dir ["git", "rev-parse", "--short", "HEAD"])))))

(defn git-update [channel root]
  (->> root 
    (io/file)
    (file-seq)
    (filter #(.isDirectory %))
    (filter #(= (.getName %) ".git"))
    (map #(.getAbsolutePath (.getParentFile %)))
    (pmap (fn [path] 
            (async/put! channel [:pulling path (git-status path)])
            (let [p (exec path ["git" "pull"])]
              (if (not= 0 (.waitFor p))
                (async/put! channel [:failed path (string/trim( slurp (.getErrorStream p)))])
                (async/put! channel [:succeeded path (git-status path)])))))
    (doall))
  (async/close! channel))

(def channel (async/chan 100000))
(async/go (git-update channel "/Users/pgaultier/projects/ppro-1648791067/"))

(time (loop [x (async/<!! channel)
             shasPerPath {}]
        (when x
          (let [[status path info] x
                shasPerPath
                  (case status
                    :pulling (do 
                               (println (format "⏳ Fetching\t%s\t%s" path info))
                               (assoc-in shasPerPath [path :before] info))
                    :failed (do 
                              (println (format "❌ %s" path))
                              shasPerPath)
                    :succeeded (do 
                                 (let [shaBefore (get-in shasPerPath [path :before])]
                                   (if (= shaBefore info)
                                     (println (format "✓ %s" path))
                                     (println (format "✓ %s\t%s -> %s" path shaBefore info))))
                                 (assoc-in shasPerPath [path :after] info))
                    nil)]
            (recur (async/<!! channel) shasPerPath)))))
