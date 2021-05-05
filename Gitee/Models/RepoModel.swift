//
//  RepoModel.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import Foundation
import SwiftUI
class RepoModel :Identifiable {
    let id: Int
    let repoName: String
    let repoPath: String
    let repoNamespace: RepoNamespace
    let repoDesc: String
    let repoForks: String
    let repoStars: String
    let repoWatches: String
    let repoLicense: String
    let repoLanguage: String
    let repoPushDate:String
    let repoIsFork:Bool
    let repoIsOpenSource:Bool
    let repoIssues: String
    let repoDefaultBranch: String
    init(
        id:Int,
        repoName:String,
        repoPath:String,
        repoNamespace:RepoNamespace,
        repoDesc:String,
        repoForks:String,
        repoStars:String,
        repoWatches:String,
        repoLicense:String,
        repoLanguage:String,
        repoPushDate:String,
        repoIsFork:Bool,
        repoIsOpenSource:Bool,
        repoIssues: String,
        repoDefaultBranch: String){
        self.id = id
        self.repoName = repoName
        self.repoPath = repoPath
        self.repoNamespace = repoNamespace
        self.repoDesc = repoDesc
        self.repoForks = repoForks
        self.repoStars = repoStars
        self.repoWatches = repoWatches
        self.repoLicense = repoLicense
        self.repoLanguage = repoLanguage
        self.repoPushDate = repoPushDate
        self.repoIsFork = repoIsFork
        self.repoIsOpenSource = repoIsOpenSource
        self.repoIssues = repoIssues
        self.repoDefaultBranch = repoDefaultBranch
    }
}
class RepoNamespace {
    let id :Int
    let name:String
    let path:String
    init(
        id: Int,
        name: String,
        path: String
    ){
        self.id = id
        self.name = name
        self.path = path
    }
}
