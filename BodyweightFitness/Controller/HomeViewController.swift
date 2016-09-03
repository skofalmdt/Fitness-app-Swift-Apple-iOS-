import Foundation
import UIKit
import RxSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var totalWorkouts: UILabel!
    @IBOutlet weak var lastWorkout: UILabel!
    @IBOutlet weak var last7Days: UILabel!
    @IBOutlet weak var last31Days: UILabel!
    
    init() {
        super.init(nibName: "HomeView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss)
        )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(routine)
        )
        
        self.navigationItem.title = "Bodyweight Fitness"
        
        self.stackView.axis = UILayoutConstraintAxis.Vertical;
        self.stackView.distribution = UIStackViewDistribution.EqualSpacing;
        self.stackView.alignment = UIStackViewAlignment.Top;
        self.stackView.spacing = 0;

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribeNext({ (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
        })

        _ = RoutineStream.sharedInstance.routineObservable().subscribeNext({ (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
        })
    }

    func renderWorkoutProgressView() {
        let routine = RoutineStream.sharedInstance.routine

        self.stackView.removeAllSubviews()
        self.navigationItem.title = routine.title

        if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
            let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()

            for category in repositoryRoutine.categories {
                let completionRate = RepositoryCategoryHelper.getCompletionRate(category)

                let homeBarView = HomeBarView()

                homeBarView.categoryTitle.text = category.title
                homeBarView.progressRate.text = completionRate.label

                self.stackView.addArrangedSubview(homeBarView)
            }
        } else {
            for category in routine.categories {
                if let c = category as? Category {
                    let homeBarView = HomeBarView()

                    homeBarView.categoryTitle.text = c.title
                    homeBarView.progressRate.text = "0%"

                    self.stackView.addArrangedSubview(homeBarView)
                }
            }
        }
    }

    func renderStatisticsView() {
        let numberOfWorkouts = RepositoryStream.sharedInstance.getNumberOfWorkouts()
//        let lastWorkout = RepositoryStream.sharedInstance.getLastWorkout()

        let numberOfWorkoutsLast7Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-7)
        let numberOfWorkoutsLast31Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-31)

        self.totalWorkouts.text = String(numberOfWorkouts) + getNumberOfWorkoutsPostfix(numberOfWorkouts)

//        if let workout = lastWorkout {
//            self.lastWorkout.text = String("TT")
//        } else {
//            self.lastWorkout.text = String("Never")
//        }

        self.last7Days.text = String(numberOfWorkoutsLast7Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast7Days)
        self.last31Days.text = String(numberOfWorkoutsLast31Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast31Days)
    }

    func getNumberOfWorkoutsPostfix(count: Int) -> String {
        if (count == 1) {
            return " Workout"
        } else {
            return " Workouts"
        }
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
    
    func routine(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Choose Workout Routine",
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.popoverPresentationController
        alertController.modalPresentationStyle = .Popover
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Bodyweight Fitness", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("routine0")
        })
        
        alertController.addAction(UIAlertAction(title: "Molding Mobility", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("e73593f4-ee17-4b9b-912a-87fa3625f63d")
        })
        
        alertController.addAction(UIAlertAction(title: "Starting Stretching", style: .Default) { (action) in
            print("Test")
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startWorkout(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        // TODO this does not select menu item on the left (in the navigation drawer)
        sideNavigationController?.transitionFromRootViewController(
            (appDelegate?.workoutViewController)!,
            duration: 0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: nil,
            completion: nil)
    }
}