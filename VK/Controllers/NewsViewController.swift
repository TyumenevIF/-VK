//
//  NewsController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 03/09/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

final class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching, NewsPostCellCellDelegate {
    
    var news: [NewsItem] = []
    var isLoading = false
    var nextFrom = ""
    lazy var service = VKService()
    
    // MARK: - Cell Helpers
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
    
    private var cellDateCache: [IndexPath: String] = [:]
    
    private func getCellDate(at indexPath: IndexPath, timestamp: TimeInterval) -> String {
        if let dateText = cellDateCache[indexPath] {
            return dateText
        } else {
            let date = Date(timeIntervalSince1970: timestamp)
            let dateText = dateFormatter.string(from: date)
            cellDateCache[indexPath] = dateText
            return dateText
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        refreshNews()
        setupRefreshControl()
    }
    
    // MARK: - setupTableView
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.prefetchDataSource = self
    }
    
    // MARK: - Refresh Control
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        
        let color = UIColor.systemBlue
        let attributes: [NSAttributedString.Key: Any] = [ .foregroundColor: color]
        
        refreshControl?.attributedTitle = NSAttributedString(string: "Reloading news...", attributes: attributes)
        refreshControl?.tintColor = color
        refreshControl?.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
    }
    
    // MARK: - refreshNews
    
    @objc private func refreshNews() {
        let mostFreshTime: TimeInterval?
        
        if let lastDate = news.first?.date {
            mostFreshTime = lastDate.timeIntervalSince1970 + 1
        } else {
            mostFreshTime = nil
        }
        
        loadNews(startTime: mostFreshTime, startFrom: nil)
    }
    
    // MARK: - loadNews
    private func loadNews(startTime: TimeInterval?, startFrom: String?) {
        isLoading = true
        
        service.getNewsfeed(startTime: startTime, startFrom: nextFrom, nil) { [weak self] (fetchedNews, next) in
            guard let strongSelf = self else { return }
            strongSelf.refreshControl?.endRefreshing()
            
            if startFrom != nil {
                let newsCount = strongSelf.news.count
                
                strongSelf.news.append(contentsOf: fetchedNews)
                strongSelf.nextFrom = next
                
                let indexPaths = (newsCount..<(newsCount + fetchedNews.count)).map { IndexPath(row: $0, section: 0) }
                strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
            } else {
                guard fetchedNews.count > 0 else { return }
                strongSelf.news = fetchedNews + strongSelf.news
                strongSelf.nextFrom = next
                
                let indexPaths = (0..<fetchedNews.count).map { IndexPath(row: $0, section: 0) }
                strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
            }
            
            strongSelf.isLoading = false
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if news.isEmpty {
            tableView.showEmptyMessage("Нет новостей.\nПотяните вниз\nдля обновления")
        } else {
            tableView.hideEmptyMessage()
        }
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = news[indexPath.row]
        
        switch item.type {
        case .post:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsPostCell", for: indexPath) as! NewsPostCell
            cell.configure(item: news[indexPath.row], dateFormatter: dateFormatter)
            cell.delegate = self
            return cell
        case .photo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsPhotoCell", for: indexPath) as! NewsPhotoCell
            cell.configure(item: news[indexPath.row], dateFormatter: dateFormatter)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = news[indexPath.row]
        
        switch item.type {
        case let .photo(cell):
            let tableWidth = tableView.bounds.width
            let cellHeight = tableWidth * (cell.photos.first?.aspectRatio ?? 1)
            return cellHeight
            
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        print(#function)
        
        guard
            let maxRow = indexPaths.map({ $0.row }).max(), // Выбираем max-й номер секции, которую нужно будет отобразить в ближайшее время
            maxRow >= news.count - 3, // Проверяем,является ли эта секция одной из трех ближайших к концу
            news.count > 3,
            isLoading == false // Убеждаемся, что мы уже не в процессе загрузки данных
        else { return }
        
        loadNews(startTime: nil, startFrom: nextFrom)
    }
    
    // MARK: - NewsPostCellCellDelegate
    func didTapShowMore(cell: NewsPostCell) {
        tableView.beginUpdates()
        cell.isExpanded.toggle()
        tableView.endUpdates()
    }    
}
