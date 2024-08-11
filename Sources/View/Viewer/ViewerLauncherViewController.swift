import UIKit

class ViewerLauncherViewController: UIViewController {
    var config: Config
    var token: TokenModel.Token

    init(config: Config, token: TokenModel.Token) {
        self.config = config
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20

        let mosaicButton = UIButton(type: .system)
        mosaicButton.setTitle("Launch Mosaic Viewer", for: .normal)
        mosaicButton.addTarget(self, action: #selector(launchMosaicViewer), for: .touchUpInside)

        let viewer3DButton = UIButton(type: .system)
        viewer3DButton.setTitle("Launch 3D Viewer", for: .normal)
        viewer3DButton.addTarget(self, action: #selector(launch3DViewer), for: .touchUpInside)

        let viewerBasicPDFButton = UIButton(type: .system)
        viewerBasicPDFButton.setTitle("Launch Basic PDF Viewer", for: .normal)
        viewerBasicPDFButton.addTarget(self, action: #selector(launchBasicPDFViewer), for: .touchUpInside)

        let viewerPDFButton = UIButton(type: .system)
        viewerPDFButton.setTitle("Launch PDF Viewer", for: .normal)
        viewerPDFButton.addTarget(self, action: #selector(launchPDFViewer), for: .touchUpInside)

        stackView.addArrangedSubview(mosaicButton)
        stackView.addArrangedSubview(viewer3DButton)
        stackView.addArrangedSubview(viewerBasicPDFButton)
        stackView.addArrangedSubview(viewerPDFButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func launchMosaicViewer() {
        let viewer = ViewerMosaicViewController()
        viewer.title = "Mosaic Viewer"
        navigationController?.pushViewController(viewer, animated: true)
    }

    @objc private func launch3DViewer() {
        let viewer = Viewer3DViewController()
        viewer.title = "3D Viewer"
        navigationController?.pushViewController(viewer, animated: true)
    }

    @objc private func launchBasicPDFViewer() {
        let viewer = ViewerPDFBasicViewController()
        viewer.title = "Basic PDF Viewer"
        navigationController?.pushViewController(viewer, animated: true)
    }

    @objc private func launchPDFViewer() {
        let viewer = ViewerPDFViewController()
        viewer.title = "PDF Viewer"
        navigationController?.pushViewController(viewer, animated: true)
    }
}
