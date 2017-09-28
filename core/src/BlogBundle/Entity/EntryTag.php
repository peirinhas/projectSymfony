<?php

namespace BlogBundle\Entity;

/**
 * EntryTag
 */
class EntryTag
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var \BlogBundle\Entity\Entries
     */
    private $entry;

    /**
     * @var \BlogBundle\Entity\Tags
     */
    private $tag;


    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set entry
     *
     * @param \BlogBundle\Entity\Entries $entry
     *
     * @return EntryTag
     */
    public function setEntry(\BlogBundle\Entity\Entries $entry = null)
    {
        $this->entry = $entry;

        return $this;
    }

    /**
     * Get entry
     *
     * @return \BlogBundle\Entity\Entries
     */
    public function getEntry()
    {
        return $this->entry;
    }

    /**
     * Set tag
     *
     * @param \BlogBundle\Entity\Tags $tag
     *
     * @return EntryTag
     */
    public function setTag(\BlogBundle\Entity\Tags $tag = null)
    {
        $this->tag = $tag;

        return $this;
    }

    /**
     * Get tag
     *
     * @return \BlogBundle\Entity\Tags
     */
    public function getTag()
    {
        return $this->tag;
    }
}

