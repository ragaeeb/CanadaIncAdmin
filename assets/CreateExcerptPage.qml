import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: createPage
    property int excerptId
    
    onExcerptIdChanged: {
        excerpts.fetchExcerpt(createPage, excerptId);
    }
    
    function cleanUp() {}
    
    Container
    {
        
    }
}