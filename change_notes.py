#!/usr/bin/env python

# This script 

import xml.dom.minidom
import subprocess
import sys
import os
import time
from datetime import timedelta, date 
class MissingRepositoryException(Exception):
    pass

def cmd(args, cwd, bufsize=8192):
    """Execute a command based on the args and current
    working directory.  Read up to the first 8K of output
    and return the output as a strip()'d string"""
    #XXX This function sucks.
    proc = subprocess.Popen(args=args, cwd=cwd,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    output=proc.stdout.read(bufsize)
    proc.wait()
    return output.strip()

def git_op(args, path):
    """Call a command using some git specific logic, like
    checking whether the directory the command is to be run
    in exists.  Raises a MissingRepositoryException if the
    repository does not exist"""
    if not os.path.isdir(path):
        print >> sys.stderr, "%s (%s) was not found" % (path, os.path.abspath(path))
        raise MissingRepositoryException("Missing the %s repository" % path)
    return cmd(args, cwd=path)

def find_rev(path):
    """Given a path, use Git to figure out what the commit id is
    for HEAD and return it as a string"""
    # Should verify that rev-parse will only ever print the rev to stdout
    return git_op(['git', 'rev-parse', 'HEAD'], path=path)

def main():
    #today = date.today()
    #yesterday = date.today() - timedelta(days=1)
    file_path1 = os.getcwd() + "/nightly/otoro/12-10-31/manifest.xml"
    file_path2 = os.getcwd() + "/nightly/otoro/12-11-01/manifest.xml"
    doc1 = xml.dom.minidom.parse(file_path1)
    doc2 = xml.dom.minidom.parse(file_path2)
    dic1 = {}
    dic2 = {}
    log = ''
    for project in doc1.getElementsByTagName("project"):
        manifest_path = project.getAttribute('path')
        commit_id = project.getAttribute('revision')
        dic1[manifest_path] = commit_id
    for project in doc2.getElementsByTagName("project"):
        manifest_path = project.getAttribute('path')
        commit_id = project.getAttribute('revision')
        dic2[manifest_path] = commit_id
    keys1 = dic1.keys()
    keys2 = dic2.keys()
    s1 = set(keys1)
    s2 = set(keys2)
    print s2.difference(s1)
    for index in range(len(keys1)):
        if keys1[index] in keys2:
            #print keys1[index]
            pass
        else:
            log += 'repository ' + keys1[index] + ' has been removed\n'
           # print log
      #  fs_path = os.path.join(root_path, manifest_path)
      #  commit_id = find_rev(fs_path)
      #  project.setAttribute('revision', commit_id)
      #  parentNode = project.parentNode
#        tag = find_ref(fs_path, only_annotated)
#        if tags and tag != commit_id:
#            comment = " Information: %s is tagged with %s " % (project.getAttribute('name'), tag)
#            parentNode.insertBefore(doc.createComment(comment), project)
    #if hasattr(out, 'write'):
    #    doc.writexml(output)
    #else:
    #    with open(out, 'w+b') as of:
    #        doc.writexml(of)

if __name__ == "__main__":
    #print time.strftime("%Y-%m-%d", time.localtime(time.time()))
    #print date.today()
    #print date.today() - timedelta(days=1)
    #root_path =  os.getcwd() + "/" + sys.argv[1]
    #out = os.getcwd() + "/" +  sys.argv[2]

    main()
