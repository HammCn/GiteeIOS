//
//  GiteeConfig.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import Foundation

struct giteeConfig {
    static let access_token = "access_token"
    static let user_name = "user_name"
    
    static let issue_filter = "issue_filter"
    static let issue_state = "issue_state"
    static let issue_sort = "issue_sort"
    static let issue_direction = "issue_direction"
    
    static let repo_type = "repo_type"
    static let repo_sort = "repo_sort"
    static let repo_direction = "repo_direction"
    
    static let pull_request_state = "pull_request_state"
    static let pull_request_sort = "pull_request_sort"
    static let pull_request_direction = "pull_request_direction"
}
struct globalConfig {
    static var canOpenByMoveToRight:Bool = false
}
