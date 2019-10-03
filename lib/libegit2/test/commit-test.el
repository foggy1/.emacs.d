(ert-deftest commit-lookup ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id))
           (commit-short (libgit-commit-lookup-prefix repo (substring id 0 7))))
      (should (libgit-commit-p commit))
      (should (string= id (libgit-commit-id commit)))
      (should (string= id (libgit-commit-id commit-short)))
      (should-error (libgit-commit-lookup repo "test") :type 'giterr-invalid))))

(ert-deftest commit-parentcount ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (= 0 (libgit-commit-parentcount commit))))
    (commit-change "test" "more content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (= 1 (libgit-commit-parentcount commit))))))

(ert-deftest commit-parent-id ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (parent-id (libgit-reference-name-to-id repo "HEAD")))
      (commit-change "test" "more content")
      (let* ((this-id (libgit-reference-name-to-id repo "HEAD"))
             (commit (libgit-commit-lookup repo this-id)))
        (should (string= parent-id (libgit-commit-parent-id commit)))
        (should (string= parent-id (libgit-commit-parent-id commit 0)))
        (should (string= parent-id (libgit-commit-id (libgit-commit-parent commit))))
        (should (string= parent-id (libgit-commit-id (libgit-commit-parent commit 0))))
        (should-error (libgit-commit-parent-id commit 1) :type 'args-out-of-range)
        (should-error (libgit-commit-parent commit 1) :type 'giterr-invalid)))))

(ert-deftest commit-ancestor ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id-1 (libgit-reference-name-to-id repo "HEAD")))
      (commit-change "test" "more content")
      (let* ((id-2 (libgit-reference-name-to-id repo "HEAD")))
        (commit-change "test" "so much content wow")
        (let* ((id-3 (libgit-reference-name-to-id repo "HEAD"))
               (commit (libgit-commit-lookup repo id-3)))
          (should (string= id-3 (libgit-commit-id (libgit-commit-nth-gen-ancestor commit 0))))
          (should (string= id-2 (libgit-commit-id (libgit-commit-nth-gen-ancestor commit 1))))
          (should (string= id-1 (libgit-commit-id (libgit-commit-nth-gen-ancestor commit 2))))
          (should-error (libgit-commit-nth-gen-ancestor commit 3) :type 'giterr-invalid)
          (should-error (libgit-commit-nth-gen-ancestor commit -1) :type 'giterr-invalid))))))

(ert-deftest commit-author-committer ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id))
           (author (libgit-commit-author commit))
           (committer (libgit-commit-committer commit)))
      (should (string= "A U Thor" (libgit-signature-name author)))
      (should (string= "author@example.com" (libgit-signature-email author)))
      (should (string= "A U Thor" (libgit-signature-name committer)))
      (should (string= "author@example.com" (libgit-signature-email committer))))))

(ert-deftest commit-message ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content" "here is a message!")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (string= "here is a message!\n" (libgit-commit-message commit))))))

(ert-deftest commit-summary ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content" "here is a message!\n\nhere is some more info")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (string= "here is a message!" (libgit-commit-summary commit)))
      (should (string= "here is some more info" (libgit-commit-body commit))))))

(ert-deftest commit-create ()
  (with-temp-dir path
    (init)
    (commit-change "b" "contents")
    (write "a" "abcdef")
    (write "b" "ghijkl")
    (write "somedir/c" "mnopqr")
    (let* ((repo (libgit-repository-open path))
           (index (libgit-repository-index repo))
           (parent (libgit-revparse-single repo "HEAD"))
           tree commit)
      (libgit-index-add-bypath index "a")
      (libgit-index-add-bypath index "b")
      (libgit-index-add-bypath index "somedir/c")
      (setq tree (libgit-tree-lookup repo (libgit-index-write-tree index)))
      (setq commit (libgit-commit-lookup
                    repo
                    (libgit-commit-create
                     repo "HEAD"
                     (libgit-signature-now "Zeus" "zeus@olympus.gr")
                     (libgit-signature-now "Hades" "hades@underworld.gr")
                     "This is a commit message"
                     tree (list parent))))
      (should (= 1 (libgit-commit-parentcount commit)))
      (should (string= (libgit-commit-id parent) (libgit-commit-parent-id commit)))
      (should (string= "Zeus" (libgit-signature-name (libgit-commit-author commit))))
      (should (string= "zeus@olympus.gr" (libgit-signature-email (libgit-commit-author commit))))
      (should (string= "Hades" (libgit-signature-name (libgit-commit-committer commit))))
      (should (string= "hades@underworld.gr" (libgit-signature-email (libgit-commit-committer commit))))
      (should (string= "This is a commit message" (libgit-commit-message commit)))
      (should (string= (libgit-tree-id tree) (libgit-commit-tree-id commit)))
      (should (string= (libgit-commit-id commit) (libgit-reference-name-to-id repo "HEAD")))
      (should (string= (libgit-commit-id commit) (libgit-reference-name-to-id repo "refs/heads/master"))))))