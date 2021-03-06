//
//  StudyDetail.swift
//  SKHUStudy
//
//  Created by Hee Jae Kim on 2020/04/29.
//  Copyright © 2020 anniversary. All rights reserved.
//

import UIKit

import FirebaseFirestore
import Then
import SnapKit

import SwiftKeychainWrapper

class StudyDetailVC: UIViewController {
    
    // MARK: - UI components
    
    @IBOutlet var studyWeeksTV: UITableView!
    
    let chatOrCreateButton = UIButton()
    
    // MARK: - Variables and Properties
    
    var studyID: Int = 0
    var isChiefUser = false
    var isWantUser = false
    
    var studyDetailInfo: StudyInfo?
    var studyChapterList: StudyChapterList?
    
    // MARK: - dummy data
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studyWeeksTV.dataSource = self
        studyWeeksTV.delegate = self
        
        // Register the custom header view
        studyWeeksTV.register(StudyDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: "StudyDetailHeaderView")
        // Register the custom cell
        studyWeeksTV.register(StudyWeekTVC.self, forCellReuseIdentifier: "StudyWeekTVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getStudyDetailInfoService(completionHandler: {(returnedData)-> Void in
            self.getStudyChapterListService(completionHandler: {returnedData-> Void in
                if self.studyDetailInfo?.data[0].chiefUser.userID == KeychainWrapper.standard.string(forKey: "userID") {
                    self.isChiefUser = true
                } else {
                    self.checkWantUser()
                }
                self.studyWeeksTV.reloadData()
                
                self.addChatOrCreateButton()
            })
        })
    }
    
    // MARK: - 채팅 기능
    @objc func didTapChatButton() {
        let chiefUserID = studyDetailInfo?.data[0].chiefUser.userID
        let chiefUserNickname = studyDetailInfo?.data[0].chiefUser.name
        let myUserID = KeychainWrapper.standard.string(forKey: "userID")!
        var roomID: String? = nil
        
        let ref = Firestore.firestore().collection("ChatRooms")
        
        ref.getDocuments { (snapshot, error) in
            if error != nil {
                return
            }
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                let dic = document.data()
                let users = dic["users"] as! [String]
                if users.contains(myUserID) && users.contains(chiefUserID!) {
                    roomID = document.documentID
                }
            }
            
            let sb = UIStoryboard(name: "Chat", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            vc.recipientID = chiefUserID!
            vc.recipientNickname = chiefUserNickname!
            print("상대방  uid는 \(chiefUserID!)")
            print("상대방 닉네임은 \(chiefUserNickname!)")
            vc.roomID = roomID
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func didTapCreateButton() {
        
        let CreateWeekSB = UIStoryboard(name: "CreateWeek", bundle: nil)
        let showCreateWeekVC = CreateWeekSB.instantiateViewController(withIdentifier: "CreateWeekVC") as! CreateWeekVC
        
        showCreateWeekVC.studyID = studyID
        
        navigationController?.pushViewController(showCreateWeekVC, animated: true)
    }
    
    // MARK: - Helper
    
    func addChatOrCreateButton() {
        _ = chatOrCreateButton.then {
            if isChiefUser == true {
                $0.setTitle("챕터 생성", for: .normal)
                $0.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
            } else {
                $0.setTitle("대화하기", for: .normal)
                $0.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)
            }
            
            $0.titleLabel?.font = Font.studyContentsLabel
            $0.makeRounded(cornerRadius: 15)
            $0.tintColor = .white
            $0.backgroundColor = .signatureColor
            
            $0.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        }
        
        view.addSubview(chatOrCreateButton)
        
        chatOrCreateButton.snp.makeConstraints{ make in
            make.width.equalTo(90)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
            
            var tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
            tabBarHeight = tabBarHeight + CGFloat(10.0)
            make.bottom.equalToSuperview().inset(tabBarHeight)
        }
    }
    
    func checkWantUser() {
        for wantUser in studyDetailInfo?.data[0].wantUser ?? [] {
            if wantUser.userID == KeychainWrapper.standard.string(forKey: "userID") {
                isWantUser = true
            }
        }
    }
    
}

// MARK: - UITableView

extension StudyDetailVC : UITableViewDelegate { }

extension StudyDetailVC : UITableViewDataSource {
    
    // Table HeaderView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StudyDetailHeaderView") as? StudyDetailHeaderView
        
        headerView?.studyDetailVC = self
        
        if (self.studyDetailInfo?.data.count != 0){
            headerView?.studyDetailInfo = self.studyDetailInfo
            headerView?.isChiefUser = isChiefUser
            headerView?.isWantUser = isWantUser
            
            headerView?.initStudyDetail()
            headerView?.addContentView()
        }
        
        return headerView
    }
    
    // Table Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudyWeekTVC", for: indexPath) as! StudyWeekTVC
        
        cell.selectionStyle = .none
        
        switch studyChapterList?.status {
        case 200:
            if studyChapterList?.data.count == 0 {
                cell.emptyLabel.isHidden = false
                cell.isUserInteractionEnabled = false
                
                cell.numberLabel.isHidden = true
                cell.dateLabel.isHidden = true
                cell.titleLabel.isHidden = true
                cell.placeButton.isHidden = true
                cell.placeImageView.isHidden = true
                
                cell.initCell()
                cell.addContentView()
                
            } else {
                cell.emptyLabel.isHidden = true
                cell.isUserInteractionEnabled = true
                
                cell.numberLabel.isHidden = false
                cell.dateLabel.isHidden = false
                cell.titleLabel.isHidden = false
                cell.placeButton.isHidden = false
                cell.placeImageView.isHidden = false
                
                cell.studyChapterInfo = studyChapterList?.data[indexPath.row]
                cell.studyOrder = (studyChapterList?.data.count ?? 0 + 1) - indexPath.row
                cell.initCell()
                cell.addContentView()
            }
            
        case 400, 406, 411, 500, 420, 421, 422, 423:
            cell.emptyLabel.isHidden = true
            cell.numberLabel.isHidden = true
            cell.dateLabel.isHidden = true
            cell.titleLabel.isHidden = true
            cell.placeButton.isHidden = true
            cell.placeImageView.isHidden = true
            
            let emptyLabel = UILabel()
            emptyLabel.text = "챕터 정보를 불러오는데 실패하였습니다😢"
            cell.addSubview(emptyLabel)
            emptyLabel.snp.makeConstraints{ (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            cell.isUserInteractionEnabled = false
            
        default:
            cell.emptyLabel.isHidden = true
            cell.numberLabel.isHidden = true
            cell.dateLabel.isHidden = true
            cell.titleLabel.isHidden = true
            cell.placeButton.isHidden = true
            cell.placeImageView.isHidden = true
            
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var chapterList = studyChapterList?.data.count ?? 0
        
        if chapterList == 0 {
            chapterList += 1
        }
        
        return chapterList
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let popUpViewVC = ChapterDetailPopUpVC()
        popUpViewVC.modalPresentationStyle = .overFullScreen
        popUpViewVC.modalTransitionStyle = .coverVertical
        
        popUpViewVC.studyDetailVC = self
        
        popUpViewVC.studyUserList = studyDetailInfo?.data[0].studyUser
        popUpViewVC.chapterListData = studyChapterList?.data[indexPath.row]
        popUpViewVC.studyOrder = (studyChapterList?.data.count ?? 0 + 1) - indexPath.row
        
        UIView.animate(withDuration: 0.2) {
            self.tabBarController?.view.alpha = 0.7
            self.tabBarController?.present(popUpViewVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Study DetailInfo & Chapter List Service

extension StudyDetailVC {
    
    func getStudyDetailInfoService(completionHandler: @escaping (_ returnedData: StudyInfo) -> Void) {
        let token = KeychainWrapper.standard.string(forKey: "token") ?? ""
        StudyService.shared.getStudyDetailInfo(token: token, id: studyID) { result in
            print("토큰 값은 \(token)")
            print("스터디 id는 \(self.studyID)")
            switch result {
            case .success(let res):
                let responseStudyInfo = res as! StudyInfo
                
                switch responseStudyInfo.status {
                case 200:
                    self.studyDetailInfo = responseStudyInfo
                    
                    completionHandler(self.studyDetailInfo!)
                    
                case 400, 406, 411, 500, 420, 421, 422, 423:
                    let presentVC = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        presentVC?.simpleAlert(title: responseStudyInfo.message, message: "")
                    })
                    
                default:
                    let presentVC = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        presentVC?.simpleAlert(title: "오류가 발생하였습니다", message: "")
                    })
                }
            case .requestErr(_):
                print(".requestErr")
            case .pathErr:
                print(".pathErr")
            case .serverErr:
                print(".serverErr")
            case .networkFail:
                print(".networkFail")
            }
            
        }
    }
    
    func getStudyChapterListService(completionHandler: @escaping (_ returnedData: StudyChapterList) -> Void) {
        let token = KeychainWrapper.standard.string(forKey: "token") ?? ""
        StudyService.shared.getStudyChapterList(token: token, id: studyID) { result in
            
            switch result {
            case .success(let res):
                let responseStudyChapterList = res as! StudyChapterList
                
                switch responseStudyChapterList.status {
                case 200:
                    self.studyChapterList = responseStudyChapterList
                    
                    completionHandler(self.studyChapterList!)
                    
                case 400, 406, 411, 500, 420, 421, 422, 423:
                    let presentVC = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        presentVC?.simpleAlert(title: responseStudyChapterList.message, message: "")
                    })
                    
                default:
                    let presentVC = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        presentVC?.simpleAlert(title: "오류가 발생하였습니다", message: "")
                    })
                }
            case .requestErr(_):
                print(".requestErr")
            case .pathErr:
                print(".pathErr")
            case .serverErr:
                print(".serverErr")
            case .networkFail:
                print(".networkFail")
            }
            
        }
    }
    
}
