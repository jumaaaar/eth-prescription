const Header = ({name}: {name: string}) => {
    return (
        <div id="header">
            <div className="prescription-icon">
                <i className="fa-solid fa-prescription fa-lg"></i>
                <span className="header-text">Prescription</span>
            </div>
            <div className="docInfo">
                <div className="docName">{name}</div>
            </div>
        </div>
    )
}

export default Header