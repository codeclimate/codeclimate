# jave file, made rb
CODE CLIMATE OPTIONS
Show issues
Show test coverage
 Highlight covered lines
   
    @Override
    public String toString() {
TODO found
      return "TODO: implement this method";
    @Override 
    public String toString() { 
        if (this.nextTag == null) {
            return this.abbreviatedCommitId;
        } else if (this.distance == 0) {
            return this.nextTag.getName();
        } else {
            if (!this.nextTag.getName().isEmpty() &&
                this.distance != 0) {
                      return String.format("%s-%d-g%s",
                          this.nextTag.getName(),
                          this.distance,
                          this.abbreviatedCommitId);
            } else {
              return "undefined";
            }
        }
