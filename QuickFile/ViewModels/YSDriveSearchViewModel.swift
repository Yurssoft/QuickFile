//
//  YSDriveSearchViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 2/20/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

class YSDriveSearchViewModel: YSDriveSearchViewModelProtocol {
    var model: YSDriveSearchModelProtocol? {
        didSet {
            updateGlobalResults()
            model?.getAllFiles {[unowned self] (localFiles, error, _) in
                self.localFilesUnfiltered = localFiles
                guard let error = error else { return }
                self.error = error
            }
        }
    }

    weak var viewDelegate: YSDriveSearchViewModelViewDelegate?
    weak var coordinatorDelegate: YSDriveSearchViewModelCoordinatorDelegate?

    var numberOfLocalFiles: Int {
        return localFiles.count
    }

    var numberOfGlobalFiles: Int {
        return globalFiles.count
    }

    var isDownloadingMetadata: Bool = false {
        didSet {
            viewDelegate?.metadataDownloadStatusDidChange(viewModel: self)
        }
    }

    var error: YSErrorProtocol = YSError() {
        didSet {
            if !error.isEmpty() {
                DispatchQueue.main.async {
                    self.viewDelegate?.errorDidChange(viewModel: self, error: self.error)
                }
            }
        }
    }

    var searchTerm = ""

    fileprivate var globalFiles = [YSDriveFileProtocol]() {
        didSet {
            viewDelegate?.filesDidChange(viewModel: self)
        }
    }

    fileprivate var localFilesUnfiltered = [YSDriveFileProtocol]() {
        didSet {
            updateLocalResults()
        }
    }

    fileprivate var localFiles = [YSDriveFileProtocol]() {
        didSet {
            viewDelegate?.filesDidChange(viewModel: self)
        }
    }

    fileprivate var nextPageToken: String?

    var sectionType: YSSearchSectionType = YSSearchSectionType(rawValue: YSSearchSectionType.all.rawValue)!

    var allPagesDownloaded = false

    func subscribeToDownloadingProgress() {
        coordinatorDelegate?.subscribeToDownloadingProgress()
    }

    func updateLocalResults() {
        if searchTerm == "" {
            let localFilesFiltered = localFilesUnfiltered.filter {
                switch sectionType {
                case .all:
                    return true
                case .files:
                    return $0.isAudio
                case .folders:
                    return !$0.isAudio
                }
            }
            localFiles = Array(localFilesFiltered.prefix(5))
            return
        }
        var localFilesFiltered = localFilesUnfiltered.filter {
            switch sectionType {
            case .all:
                return $0.fileName.contains(searchTerm)
            case .files:
                return $0.isAudio && $0.fileName.contains(searchTerm)
            case .folders:
                return !$0.isAudio && $0.fileName.contains(searchTerm)
            }
        }
        localFilesFiltered = Array(localFilesFiltered.prefix(5))
        localFiles = localFilesFiltered
    }

    func updateGlobalResults() {
        nextPageToken = nil
        getFiles {[unowned self] (files) in
            self.globalFiles = files
        }
    }

    func getNextPartOfFiles(_ completion: @escaping () -> Swift.Void) {
        guard nextPageToken != nil, !isDownloadingMetadata else {
            completion()
            return
        }
        getFiles {[unowned self]  (files) in
            self.globalFiles += files
            self.callCompletion(completion)
        }
    }

    func file(at indexPath: IndexPath) -> YSDriveFileProtocol? {
        switch YSSearchSection(rawValue: indexPath.section)! {
        case .localFiles:
            if localFiles.count > indexPath.row {
                return localFiles[indexPath.row]
            }
        case .globalFiles:
            if globalFiles.count > indexPath.row {
                return globalFiles[indexPath.row]
            }
        }
        viewDelegate?.filesDidChange(viewModel: self)
        return YSDriveFile()
    }

    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol? {
        return model?.download(for: fileDriveIdentifier)
    }

    func useFile(at indexPath: IndexPath) {
        switch YSSearchSection(rawValue: indexPath.section)! {
        case .localFiles:
            guard let coordinatorDelegate = coordinatorDelegate, indexPath.row < localFiles.count else { return }
            coordinatorDelegate.searchViewModelDidSelectFile(self, file: localFiles[indexPath.row])
        case .globalFiles:
            guard let coordinatorDelegate = coordinatorDelegate, indexPath.row < globalFiles.count else { return }
            coordinatorDelegate.searchViewModelDidSelectFile(self, file: globalFiles[indexPath.row])
        }
    }

    fileprivate func getFiles(_ completion: @escaping FilesCH) {
        isDownloadingMetadata = true
        model?.getFiles(for: searchTerm, sectionType: sectionType, nextPageToken: nextPageToken) {[unowned self] (files, error, nextPageToken) in
            if let errorDebugInfo = error?.debugInfo, errorDebugInfo.contains("cancelled") {
                return
            }
            self.nextPageToken = nextPageToken
            self.isDownloadingMetadata = false
            self.error = error!
            self.allPagesDownloaded = nextPageToken == nil
            completion(files)
        }
    }

    func searchViewControllerDidFinish() {
        coordinatorDelegate?.searchViewModelDidFinish()
    }

    func download(_ fileDriveIdentifier: String) {
        var allFiles = globalFiles + localFilesUnfiltered
        allFiles = allFiles.filter({ $0.fileDriveIdentifier == fileDriveIdentifier })
        guard let file = allFiles.first else { return }
        model?.upfateFileGeneralInfo(for: file)
        model?.download(fileDriveIdentifier)
    }

    func stopDownloading(_ fileDriveIdentifier: String) {
        model?.stopDownload(fileDriveIdentifier)
    }

    func indexPath(of file: YSDriveFileProtocol) -> IndexPath {
        if let index = localFiles.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier}) {
            return IndexPath.init(row: index, section: YSSearchSection.localFiles.rawValue)
        }
        if let index = globalFiles.index(where: {$0.fileDriveIdentifier == file.fileDriveIdentifier}) {
            return IndexPath.init(row: index, section: YSSearchSection.localFiles.rawValue)
        }
        return IndexPath.init(row: 0, section: 0)
    }
}

extension YSDriveSearchViewModel: YSUpdatingDelegate {
    internal func filesDidChange() {
        self.viewDelegate?.filesDidChange(viewModel: self)
    }

    func downloadDidChange(_ download: YSDownloadProtocol, _ error: YSErrorProtocol?) {
        if let error = error {
            self.viewDelegate?.downloadErrorDidChange(viewModel: self, error: error, download: download)
        }
        var index = self.localFiles.index(where: {$0.fileDriveIdentifier == download.fileDriveIdentifier})
        if let indexx = index, self.localFiles.count > indexx {
            self.viewDelegate?.reloadFileDownload(at: indexx, download: download, viewModel: self)
        }

        index = self.globalFiles.index(where: {$0.fileDriveIdentifier == download.fileDriveIdentifier})
        guard let indexx = index, self.globalFiles.count > indexx else { return }
        self.viewDelegate?.reloadFileDownload(at: indexx, download: download, viewModel: self)
    }
}
